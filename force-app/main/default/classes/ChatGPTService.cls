/**
 * Service class for interacting with OpenAI API
 * Provides methods for chat completions with configurable models and parameters
 */
public with sharing class ChatGPTService {
    
    // Constants for OpenAI models
    public static final String MODEL_GPT_41 = 'gpt-4.1';
    public static final String MODEL_GPT_4O = 'gpt-4o';
    
    // API Configuration
    private static final String OPENAI_ENDPOINT = 'https://api.openai.com/v1/chat/completions';
    private static final Integer DEFAULT_MAX_TOKENS = 1000;
    private static final Decimal DEFAULT_TEMPERATURE = 0;
    
    // Model options for the frontend
    public static final List<ModelOption> AVAILABLE_MODELS = new List<ModelOption>{
        new ModelOption('GPT-4o', MODEL_GPT_4O),
        new ModelOption('GPT-4.1', MODEL_GPT_41)
    };
    
    // Model option wrapper for frontend
    public class ModelOption {
        @AuraEnabled public String label;
        @AuraEnabled public String value;
        
        public ModelOption(String label, String value) {
            this.label = label;
            this.value = value;
        }
    }
    
    // Configuration class for AI service settings
    public class AIServiceConfig {
        @AuraEnabled public String apiKey;
        @AuraEnabled public String endpoint;
        @AuraEnabled public String model;
        @AuraEnabled public Decimal temperature;
        
        public AIServiceConfig(String apiKey, String endpoint, String model, Decimal temperature) {
            this.apiKey = apiKey;
            this.endpoint = endpoint;
            this.model = model;
            this.temperature = temperature;
        }
    }
    
    // Request wrapper for AI service
    public class AIRequest {
        @AuraEnabled public String model;
        @AuraEnabled public List<Message> messages;
        @AuraEnabled public Decimal temperature;
        @AuraEnabled public Integer max_tokens;
        
        public AIRequest(String model, List<Message> messages, Decimal temperature, Integer maxTokens) {
            this.model = model;
            this.messages = messages;
            this.temperature = temperature;
            this.max_tokens = maxTokens;
        }
    }
    
    // Message wrapper for conversation
    public class Message {
        @AuraEnabled public String role;
        @AuraEnabled public String content;
        
        public Message(String role, String content) {
            this.role = role;
            this.content = content;
        }
    }
    
    // Response wrapper from AI service
    public class AIResponse {
        @AuraEnabled public String id;
        @AuraEnabled public String object_type;
        @AuraEnabled public Long created;
        @AuraEnabled public String model;
        @AuraEnabled public List<Choice> choices;
        @AuraEnabled public Usage usage;
    }
    
    public class Choice {
        @AuraEnabled public Integer index;
        @AuraEnabled public Message message;
        @AuraEnabled public String finish_reason;
    }
    
    public class Usage {
        @AuraEnabled public Integer prompt_tokens;
        @AuraEnabled public Integer completion_tokens;
        @AuraEnabled public Integer total_tokens;
    }
    
    // Custom exceptions
    public class OpenAIException extends Exception {}
    public class OpenAIRateLimitException extends Exception {}
    public class OpenAIConfigException extends Exception {}
    
    /**
     * Get AI response from the configured service
     * @param userMessage The user's input message
     * @param model The AI model to use
     * @param temperature The temperature setting for creativity
     * @return The AI response as a string
     */
    @AuraEnabled(cacheable=false)
    public static String getAIResponse(String userMessage, String model, Decimal temperature) {
        try {
            validateInputs(userMessage, model, temperature);
            
            AIServiceConfig config = getServiceConfig(model, temperature);
            List<Message> messages = createChatMessages(userMessage);
            AIRequest request = createAIRequest(config, messages);
            
            String responseBody = makeAPICall(config, request);
            return parseAIResponse(responseBody);
            
        } catch (Exception e) {
            System.debug('Error in getAIResponse: ' + e.getMessage());
            throw new AuraHandledException('Failed to get AI response: ' + e.getMessage());
        }
    }
    
    /**
     * Get available models for the frontend
     * @return List of available model options
     */
    @AuraEnabled(cacheable=true)
    public static List<ModelOption> getAvailableModels() {
        return AVAILABLE_MODELS;
    }
    
    /**
     * Validate input parameters
     * @param userMessage The user message to validate
     * @param model The model to validate
     * @param temperature The temperature to validate
     */
    private static void validateInputs(String userMessage, String model, Decimal temperature) {
        if (String.isBlank(userMessage)) {
            throw new OpenAIException('User message cannot be empty');
        }
        
        if (String.isBlank(model)) {
            throw new OpenAIException('Model cannot be empty');
        }
        
        if (temperature < 0 || temperature > 1) {
            throw new OpenAIException('Temperature must be between 0 and 1');
        }
        
        // Validate model is in available models
        Boolean validModel = false;
        for (ModelOption option : AVAILABLE_MODELS) {
            if (option.value == model) {
                validModel = true;
                break;
            }
        }
        
        if (!validModel) {
            throw new OpenAIException('Invalid model: ' + model);
        }
    }
    
    /**
     * Get service configuration from Custom Settings
     * @param model The AI model to use
     * @param temperature The temperature setting
     * @return AIServiceConfig object
     */
    private static AIServiceConfig getServiceConfig(String model, Decimal temperature) {
        AI_API_Settings__c settings = AI_API_Settings__c.getInstance();
        
        if (settings == null || String.isBlank(settings.OpenAI_API_Key__c)) {
            throw new OpenAIConfigException('OpenAI API key not configured. Please set up the Custom Setting.');
        }
        
        return new AIServiceConfig(
            settings.OpenAI_API_Key__c,
            OPENAI_ENDPOINT,
            model,
            temperature
        );
    }
    
    /**
     * Create chat messages for the API request
     * @param userMessage The user's message
     * @return List of Message objects
     */
    private static List<Message> createChatMessages(String userMessage) {
        return new List<Message>{
            new Message('system', 'You are a helpful assistant that provides clear, structured responses.'),
            new Message('user', userMessage)
        };
    }
    
    /**
     * Create AI request object
     * @param config The service configuration
     * @param messages The chat messages
     * @return AIRequest object
     */
    private static AIRequest createAIRequest(AIServiceConfig config, List<Message> messages) {
        return new AIRequest(
            config.model,
            messages,
            config.temperature,
            DEFAULT_MAX_TOKENS
        );
    }
    
    /**
     * Make the actual API call to the AI service
     * @param config The service configuration
     * @param request The AI request object
     * @return Response body as string
     */
    private static String makeAPICall(AIServiceConfig config, AIRequest request) {
        Http http = new Http();
        HttpRequest httpRequest = createHttpRequest(config, request);
                
        HttpResponse response = http.send(httpRequest);
        
        if (response.getStatusCode() == 429) {
            throw new OpenAIRateLimitException('Rate limit exceeded. Please try again later.');
        } else if (response.getStatusCode() != 200) {
            throw new OpenAIException('API call failed with status: ' + response.getStatusCode() + ' - ' + response.getBody());
        }
        
        return response.getBody();
    }
    
    /**
     * Create HTTP request for API call
     * @param config The service configuration
     * @param request The AI request object
     * @return HttpRequest object
     */
    private static HttpRequest createHttpRequest(AIServiceConfig config, AIRequest request) {
        HttpRequest httpRequest = new HttpRequest();
        httpRequest.setEndpoint(config.endpoint);
        httpRequest.setMethod('POST');
        httpRequest.setHeader('Content-Type', 'application/json');
        httpRequest.setHeader('Authorization', 'Bearer ' + config.apiKey);
        httpRequest.setTimeout(120000); // 2 minutes timeout
        
        // OpenAI request format
        Map<String, Object> requestBody = new Map<String, Object>{
            'model' => request.model,
            'messages' => request.messages,
            'temperature' => request.temperature,
            'max_tokens' => request.max_tokens
        };
        
        httpRequest.setBody(JSON.serialize(requestBody));
        return httpRequest;
    }
    
    /**
     * Parse the AI response from JSON
     * @param responseBody The response body as string
     * @return The AI response content
     */
    private static String parseAIResponse(String responseBody) {
        Map<String, Object> response = (Map<String, Object>) JSON.deserializeUntyped(responseBody);
        
        if (response.containsKey('error')) {
            Map<String, Object> error = (Map<String, Object>) response.get('error');
            throw new OpenAIException((String) error.get('message'));
        }
        
        List<Object> choices = (List<Object>) response.get('choices');
        if (choices == null || choices.isEmpty()) {
            throw new OpenAIException('No response received from OpenAI');
        }
        
        Map<String, Object> choice = (Map<String, Object>) choices.get(0);
        Map<String, Object> message = (Map<String, Object>) choice.get('message');
        
        return (String) message.get('content');
    }
    
    /**
     * Test method to verify the service is working
     * @return Test result message
     */
    @AuraEnabled(cacheable=false)
    public static String testConnection() {
        try {
            String response = getAIResponse('Hello, this is a test message.', MODEL_GPT_41, DEFAULT_TEMPERATURE);
            return 'Connection successful! Response: ' + response;
        } catch (Exception e) {
            return 'Connection failed: ' + e.getMessage();
        }
    }
} 