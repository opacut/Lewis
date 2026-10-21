require "net/http"
require "uri"
require "base64"
require "json"

class BookVisionService
  def initialize(image_file)
    @image_file = image_file
  end

  def extract_metadata
    image_data = Base64.strict_encode64(@image_file.read)
    @image_file.rewind

    payload = {
      model: OllamaConfig::MODEL,
      prompt: "Extract the book title and author from this book cover. Return ONLY a JSON object like: {\"title\": \"Book Name\", \"author\": \"Author Name\"}",
      images: [image_data],
      format: "json",
      stream: false
    }

    uri = URI("#{OllamaConfig::BASE_URL}/api/generate")
    response = Net::HTTP.post(uri, payload.to_json, "Content-Type" => "application/json")

    #return nil unless response.is_a?(Net::HTTPSuccess)

    result = JSON.parse(response.body)
    content = result["response"]

    #cleaned_content = content

    json_match = content.match(/\{.*\}/m)
    JSON.parse(json_match[0]) if json_match
  rescue => e
    Rails.logger.error "Ollama error: #{e.message}"
    nil
  end
end
