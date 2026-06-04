//
//  AIAnalysisService.swift
//  WakeFit
//
//  OpenAI API integration for nutrition analysis
//  Sends food logs to GPT-4o and parses structured JSON response
//

import Foundation

/// Service that communicates with OpenAI API to analyze food logs
/// and return structured nutrition data
@Observable
class AIAnalysisService {

    // MARK: - Properties

    /// Error message to display to user if API call fails
    var errorMessage: String? = nil

    /// OpenAI API endpoint for chat completions
    private let apiURL = "https://api.openai.com/v1/chat/completions"

    /// GPT model to use (gpt-4o is latest and most capable)
    private let model = "gpt-4o"

    // MARK: - Main Analysis Function

    /// Analyzes a day's food logs using OpenAI's GPT-4o model
    /// - Parameter foodText: Combined string of all food entries from today
    /// - Returns: Parsed AIAnalysis object with calories, protein, status, etc.
    /// - Throws: NetworkError if API call fails or response is invalid
    func analyzeDay(foodText: String) async throws -> AnalysisResponse {
        // Step 1: Validate API key exists
        guard APIKeys.openAI != "YOUR_OPENAI_API_KEY_HERE" else {
            throw NetworkError.missingAPIKey
        }

        // Step 2: Build the prompt for GPT
        let systemPrompt = buildSystemPrompt()
        let userPrompt = buildUserPrompt(foodText: foodText)

        // Step 3: Create the API request
        let request = try buildRequest(systemPrompt: systemPrompt, userPrompt: userPrompt)

        // Step 4: Send request and get response
        let (data, response) = try await URLSession.shared.data(for: request)

        // Step 5: Validate HTTP status code
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw NetworkError.badResponse
        }

        // Step 6: Parse OpenAI's response structure
        let openAIResponse = try JSONDecoder().decode(OpenAIResponse.self, from: data)

        // Step 7: Extract the JSON content from GPT's message
        guard let jsonString = openAIResponse.choices.first?.message.content else {
            throw NetworkError.invalidJSON
        }

        // Step 8: Clean up the JSON string (GPT sometimes wraps it in markdown)
        let cleanedJSON = cleanJSONString(jsonString)

        // Step 9: Parse the nutrition analysis JSON
        guard let jsonData = cleanedJSON.data(using: .utf8) else {
            throw NetworkError.invalidJSON
        }

        let analysisResponse = try JSONDecoder().decode(AnalysisResponse.self, from: jsonData)

        return analysisResponse
    }

    // MARK: - Prompt Building

    /// Builds the system prompt that tells GPT how to behave
    /// This is the "personality" of the AI coach
    private func buildSystemPrompt() -> String {
        return """
        You are a nutrition and discipline coach. Your job is to analyze food logs and return structured feedback.

        CRITICAL: You must return ONLY valid JSON. No markdown formatting, no code blocks, no extra text.

        Return this exact JSON structure:
        {
          "estimatedCalories": <integer>,
          "estimatedProtein": <integer>,
          "riskAreas": "<string with line breaks for multiple items>",
          "disciplineStatus": "<Disciplined | Borderline | Off Track>",
          "coachDiagnosis": "<2-3 sentence analysis>",
          "tomorrowAdvice": "<1-2 sentence actionable tip>"
        }

        Rules for analysis:
        - estimatedCalories: Total calories across all meals
        - estimatedProtein: Total protein in grams
        - riskAreas: Identify issues like high sodium, sugar, poor timing, etc. Separate issues with newlines.
        - disciplineStatus: "Disciplined" if eating clean/balanced, "Borderline" if some issues, "Off Track" if major problems
        - coachDiagnosis: Be direct and honest. Use a calm, clinical tone.
        - tomorrowAdvice: One concrete action to improve tomorrow

        If food log is very short or vague, make reasonable estimates based on typical portions.
        """
    }

    /// Builds the user prompt containing today's food logs
    /// - Parameter foodText: Combined food entries like "[morning] eggs, toast\n[afternoon] salad"
    private func buildUserPrompt(foodText: String) -> String {
        return """
        Analyze this food log:

        \(foodText)

        Return the JSON analysis now.
        """
    }

    // MARK: - Request Building

    /// Constructs the URLRequest for OpenAI API
    /// - Parameters:
    ///   - systemPrompt: Instructions for how GPT should behave
    ///   - userPrompt: The actual food log data to analyze
    /// - Returns: Configured URLRequest ready to send
    private func buildRequest(systemPrompt: String, userPrompt: String) throws -> URLRequest {
        guard let url = URL(string: apiURL) else {
            throw NetworkError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(APIKeys.openAI)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        // Build request body matching OpenAI's API spec
        let requestBody: [String: Any] = [
            "model": model,
            "messages": [
                [
                    "role": "system",
                    "content": systemPrompt
                ],
                [
                    "role": "user",
                    "content": userPrompt
                ]
            ],
            "temperature": 0.7,  // Some creativity, but not too random
            "max_tokens": 500    // Limit response length
        ]

        request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)

        return request
    }

    // MARK: - JSON Cleaning

    /// Removes markdown code fences if GPT wrapped the JSON
    /// Example: "```json\n{...}\n```" becomes "{...}"
    private func cleanJSONString(_ string: String) -> String {
        var cleaned = string.trimmingCharacters(in: .whitespacesAndNewlines)

        // Remove markdown code fences
        if cleaned.hasPrefix("```json") {
            cleaned = cleaned.replacingOccurrences(of: "```json", with: "")
        }
        if cleaned.hasPrefix("```") {
            cleaned = cleaned.replacingOccurrences(of: "```", with: "")
        }
        if cleaned.hasSuffix("```") {
            cleaned = String(cleaned.dropLast(3))
        }

        return cleaned.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

// MARK: - Response Models

/// OpenAI API top-level response structure
/// This is what comes back from the /chat/completions endpoint
struct OpenAIResponse: Codable {
    let choices: [Choice]

    struct Choice: Codable {
        let message: Message
    }

    struct Message: Codable {
        let content: String
    }
}

/// The nutrition analysis data we expect from GPT
/// This matches the JSON structure we asked GPT to return
struct AnalysisResponse: Codable {
    let estimatedCalories: Int
    let estimatedProtein: Int
    let riskAreas: String
    let disciplineStatus: String
    let coachDiagnosis: String
    let tomorrowAdvice: String
}

// MARK: - Error Types

/// Custom errors for network and API issues
enum NetworkError: LocalizedError {
    case invalidURL
    case missingAPIKey
    case badResponse
    case invalidJSON

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid API URL"
        case .missingAPIKey:
            return "OpenAI API key not configured. Add your key to Utilities/Secrets.swift"
        case .badResponse:
            return "API request failed. Check your internet connection."
        case .invalidJSON:
            return "Failed to parse API response. Try again."
        }
    }
}
