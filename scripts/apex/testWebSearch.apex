// Test Web Search Debug Script
// Run this in Developer Console to test web search functionality

try {
    // Test 1: Get API Key
    String apiKey = Anthropic.getAnthropicApiKey();
    System.debug('API Key: ' + (apiKey != null ? 'Found' : 'Missing'));
    
    if (String.isBlank(apiKey)) {
        System.debug('ERROR: API Key is missing. Please check your AI API Settings.');
        return;
    }
    
    // Test 2: Test web search with Claude Opus 4
    String response = Anthropic.getReply(
        'claude-opus-4-20250514', 
        'What is the latest news about AI?', 
        0, 
        apiKey
    );
    
    System.debug('SUCCESS: Web search response received');
    System.debug('Response length: ' + response.length());
    System.debug('Response preview: ' + response.substring(0, Math.min(200, response.length())));
    
} catch (Exception e) {
    System.debug('ERROR: ' + e.getMessage());
    System.debug('Stack trace: ' + e.getStackTraceString());
} 