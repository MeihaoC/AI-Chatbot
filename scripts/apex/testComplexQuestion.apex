String complexQuestion = 'Can you explain the concept of machine learning, including supervised and unsupervised learning, with examples of real-world applications?';
String result = ChatGPTService.getAIResponse(complexQuestion, 'gpt-3.5-turbo', 0.7);
System.debug('Complex Question Result: ' + result); 