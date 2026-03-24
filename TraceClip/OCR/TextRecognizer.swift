import Vision

enum TextRecognizer {
    /// Recognizes text in the given image using Vision.
    /// Runs synchronously on the calling thread — dispatch to a background queue.
    /// Returns the recognized text, or nil if no text was found.
    nonisolated static func recognizeText(in image: CGImage) -> String? {
        var result: String?
        let request = VNRecognizeTextRequest { request, _ in
            let observations = request.results as? [VNRecognizedTextObservation] ?? []
            let lines = observations.compactMap { $0.topCandidates(1).first?.string }
            if !lines.isEmpty {
                result = lines.joined(separator: "\n")
            }
        }
        request.recognitionLevel = .accurate

        let handler = VNImageRequestHandler(cgImage: image, options: [:])
        try? handler.perform([request])
        return result
    }
}
