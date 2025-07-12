/**
 * Test class for AnthropicController
 * Tests the LWC-facing methods in the controller
 */
@isTest
private class AnthropicControllerTest {
    
    @TestSetup
    static void setupTestData() {
        // Create test Custom Setting data
        AI_API_Settings__c settings = new AI_API_Settings__c();
        settings.Anthropic_API_Key__c = 'test-api-key-123';
        insert settings;
    }
    
    @isTest
    static void testGetAnthropicApiKey() {
        // Test getting API key from Custom Settings
        Test.startTest();
        String apiKey = AnthropicController.getAnthropicApiKey();
        Test.stopTest();
        
        // Assertions
        System.assertNotEquals(null, apiKey, 'API key should not be null');
        System.assertEquals('test-api-key-123', apiKey, 'API key should match test value');
    }
    
    @isTest
    static void testGetAvailableModels() {
        // Test getting available models
        Test.startTest();
        List<AnthropicController.ModelOption> models = AnthropicController.getAvailableModels();
        Test.stopTest();
        
        // Assertions
        System.assertNotEquals(null, models, 'Models list should not be null');
        System.assertEquals(3, models.size(), 'Should return 3 models');
        
        // Check specific models
        Boolean hasOpus4 = false;
        Boolean hasSonnet4 = false;
        Boolean hasSonnet37 = false;
        
        for (AnthropicController.ModelOption model : models) {
            if (model.value == 'claude-opus-4-20250514') hasOpus4 = true;
            if (model.value == 'claude-sonnet-4-20250514') hasSonnet4 = true;
            if (model.value == 'claude-3-7-sonnet-20250219') hasSonnet37 = true;
        }
        
        System.assert(hasOpus4, 'Should include Claude Opus 4');
        System.assert(hasSonnet4, 'Should include Claude Sonnet 4');
        System.assert(hasSonnet37, 'Should include Claude Sonnet 3.7');
    }
    
    @isTest
    static void testGetReplyWithValidApiKey() {
        // Test getting reply with valid API key
        Test.startTest();
        
        // Mock the HTTP callout
        Test.setMock(HttpCalloutMock.class, new AnthropicMockResponse());
        
        String response = AnthropicController.getReply(
            'claude-opus-4-20250514',
            'Hello, how are you?',
            0.7,
            'test-api-key-123'
        );
        
        Test.stopTest();
        
        // Assertions
        System.assertNotEquals(null, response, 'Response should not be null');
    }
    
    @isTest
    static void testGetReplyWithBlankApiKey() {
        // Test getting reply with blank API key
        Test.startTest();
        
        try {
            AnthropicController.getReply(
                'claude-opus-4-20250514',
                'Hello, how are you?',
                0.7,
                ''
            );
            System.assert(false, 'Should have thrown an exception');
        } catch (AnthropicController.AnthropicException e) {
            System.assertEquals('Anthropic API key is required.', e.getMessage(), 'Should throw correct error message');
        }
        
        Test.stopTest();
    }
    
    @isTest
    static void testTestWebSearch() {
        // Test web search functionality
        Test.startTest();
        
        // Mock the HTTP callout
        Test.setMock(HttpCalloutMock.class, new AnthropicMockResponse());
        
        String result = AnthropicController.testWebSearch();
        
        Test.stopTest();
        
        // Assertions
        System.assertNotEquals(null, result, 'Test result should not be null');
        System.assert(result.contains('test'), 'Should contain test-related content');
    }
    
    // Mock HTTP response class
    private class AnthropicMockResponse implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            // Create a mock response
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setStatusCode(200);
            
            // Mock Anthropic response format
            String mockResponse = '{"content":[{"type":"text","text":"Hello! I am Claude, an AI assistant. How can I help you today?"}]}';
            res.setBody(mockResponse);
            
            return res;
        }
    }
} 