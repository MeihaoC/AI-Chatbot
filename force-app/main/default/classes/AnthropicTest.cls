@isTest
private class AnthropicTest {
    
    // Test constants
    private static final String RESPONSE_TEXT = 'there was a beautiful response.';
    private static final String UNAUTHORIZED_RESPONSE_TEXT = 'Incorrect API key provided: wrong key. You can find your API key at https://platform.openai.com/account/api-keys.';

    // Mock responses
    private static final String GPT_MOCK_TEXT_RESPONSE = '{"id":"msg_01KJHDY7N8B1X5ZQ3A2C0VWEF","type":"message","role":"assistant","content":[{"type":"text","text":"'+ RESPONSE_TEXT+ '"}],"model":"claude-sonnet-4-20250514","stop_reason":"end_turn","usage":{"input_tokens":8,"output_tokens":6}}';
    
    private static final String UNAUTHORIZED_RESPONSE = '{"error":{"code":401,"message":"' + UNAUTHORIZED_RESPONSE_TEXT + '","type":"invalid_request_error","param":null}}';
    
    private static final String RATE_LIMIT_RESPONSE = '{"error":{"message":"You have exceeded your rate limit. Please try again later.","type":"rate_limit_error","param":null,"code":"rate_limit_exceeded"}}';

    private static final Decimal temp = 0.5;
    private static final String model = 'claude-opus-4-20250514';
    private static final String prompt = 'Hello, how are you?';
    
    private static final String validApiKey = 'test-api-key-12345';

    /**
     * Tests that a message is received upon a successful callout to Anthropic.
     */
    @isTest
    private static void testAnthropicSuccess() {
        Test.setMock(HttpCalloutMock.class, new AnthropicMock(GPT_MOCK_TEXT_RESPONSE));

        Test.startTest();
        Anthropic apiInstance = new Anthropic(model, validApiKey, temp);
        String testResponse = apiInstance.getReply(prompt);
        Test.stopTest();

        Assert.areEqual(RESPONSE_TEXT, testResponse);
    }

    /**
     * Tests that an exception is thrown when an invalid API key is provided.
     */
    @IsTest
    private static void testAnthropicInvalidAPIKey() {
        Test.setMock(HttpCalloutMock.class, new AnthropicMock(UNAUTHORIZED_RESPONSE, 401));

        try {
            Test.startTest();
            Anthropic apiInstance = new Anthropic(model, validApiKey, temp);
            apiInstance.getReply(prompt);
            Test.stopTest();
            Assert.fail('Throw Anthropic.AnthropicException exception');
        } catch (Exception baseException) {
            Assert.isInstanceOfType(baseException, Anthropic.AnthropicException.class, 'Exception is not of type Anthropic.AnthropicException');
        }
    }

    /**
     * Tests that the custom rate limit exception is thrown when the rate limit is exceeded.
     */
    @IsTest
    private static void testAnthropicRateLimitException() {
        Test.setMock(HttpCalloutMock.class, new AnthropicMock(RATE_LIMIT_RESPONSE, 429));

        try {
            Test.startTest();
            Anthropic apiInstance = new Anthropic(model, validApiKey, temp);
            apiInstance.getReply(prompt);
            Test.stopTest();
            Assert.fail('Throw Anthropic.AnthropicRateLimitException exception');
        } catch (Exception baseException) {
            Assert.isInstanceOfType(baseException, Anthropic.AnthropicRateLimitException.class, 'Exception is not of type Anthropic.AnthropicRateLimitException');
        }
    }

    /**
     * Mock class for Anthropic API
     */
    public class AnthropicMock implements HttpCalloutMock {
        private final String responseMessage;
        private Integer responseCode = 200;

        public AnthropicMock(String responseMessage) {
            this.responseMessage = responseMessage;
        }

        public AnthropicMock(String responseMessage, Integer responseCode) {
            this.responseMessage = responseMessage;
            this.responseCode = responseCode;
        }

        public HttpResponse respond(HttpRequest req) {
            HttpResponse resp = new HttpResponse();
            resp.setStatusCode(this.responseCode);
            resp.setBody(responseMessage);
            resp.setHeader('Content-Type', 'application/json');
            return resp;
        }
    }
}