module OllamaConfig
  BASE_URL = ENV.fetch("OLLAMA_URL")
  MODEL = ENV.fetch("OLLAMA_MODEL")
end
