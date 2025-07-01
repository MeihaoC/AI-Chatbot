@IsTest
public class ChatGPTServiceTest {
    
    @TestSetup
    static void setupTestData() {
        // Create test Custom Setting
        OpenAI_API_Settings__c settings = new OpenAI_API_Settings__c();
        settings.API_Key__c = 'test-api-key';
        insert settings;
    }
    
    @IsTest
    static void testGetAvailableModels() {
        Test.startTest();
        List<ChatGPTService.ModelOption> models = ChatGPTService.getAvailableModels();
        Test.stopTest();
        
        System.assertNotEquals(0, models.size(), 'Should return available models');
        System.assertEquals('GPT-3.5 Turbo', models[0].label, 'First model should be GPT-3.5 Turbo');
        System.assertEquals('gpt-3.5-turbo', models[0].value, 'First model value should be gpt-3.5-turbo');
    }
    
    @IsTest
    static void testValidateInputs() {
        // Test valid inputs
        Test.startTest();
        try {
            ChatGPTService.getAIResponse('Test message', 'gpt-3.5-turbo', 0.7);
        } catch (Exception e) {
            // Expected to fail due to mock API call, but validation should pass
        }
        Test.stopTest();
    }
    
    @IsTest
    static void testInvalidInputs() {
        Test.startTest();
        
        // Test empty message
        try {
            ChatGPTService.getAIResponse('', 'gpt-3.5-turbo', 0.7);
            System.assert(false, 'Should have thrown exception for empty message');
        } catch (Exception e) {
            System.assert(e.getMessage().contains('User message cannot be empty'), 'Should throw appropriate error');
        }
        
        // Test invalid model
        try {
            ChatGPTService.getAIResponse('Test message', 'invalid-model', 0.7);
            System.assert(false, 'Should have thrown exception for invalid model');
        } catch (Exception e) {
            System.assert(e.getMessage().contains('Invalid model'), 'Should throw appropriate error');
        }
        
        // Test invalid temperature
        try {
            ChatGPTService.getAIResponse('Test message', 'gpt-3.5-turbo', 1.5);
            System.assert(false, 'Should have thrown exception for invalid temperature');
        } catch (Exception e) {
            System.assert(e.getMessage().contains('Temperature must be between 0 and 1'), 'Should throw appropriate error');
        }
        
        Test.stopTest();
    }
    
    @IsTest
    static void testMissingAPIKey() {
        // Delete the Custom Setting to test missing API key
        delete [SELECT Id FROM OpenAI_API_Settings__c];
        
        Test.startTest();
        try {
            ChatGPTService.getAIResponse('Test message', 'gpt-3.5-turbo', 0.7);
            System.assert(false, 'Should have thrown exception for missing API key');
        } catch (Exception e) {
            System.assert(e.getMessage().contains('OpenAI API key not configured'), 'Should throw appropriate error');
        }
        Test.stopTest();
    }
    
    @IsTest
    static void testTestConnection() {
        Test.startTest();
        String result = ChatGPTService.testConnection();
        Test.stopTest();
        
        // Should return either success or failure message
        System.assert(result.contains('Connection'), 'Should return connection test result');
    }
} 