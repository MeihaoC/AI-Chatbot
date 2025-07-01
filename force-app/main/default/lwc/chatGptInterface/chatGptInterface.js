import { LightningElement, track, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getAIResponse from '@salesforce/apex/ChatGPTService.getAIResponse';
import getAvailableModels from '@salesforce/apex/ChatGPTService.getAvailableModels';
import getAnthropicResponse from '@salesforce/apex/Anthropic.getReply';
import getAnthropicApiKey from '@salesforce/apex/Anthropic.getAnthropicApiKey';

export default class ChatGptInterface extends LightningElement {
    @track messages = [];
    @track userInput = '';
    @track selectedModel = 'gpt-4o';
    @track temperature = 0;
    @track isLoading = false;
    @track modelOptions = [];
    @track anthropicApiKey = '';

    // Wire the Anthropic API key from Apex
    @wire(getAnthropicApiKey)
    wiredAnthropicApiKey({ error, data }) {
        if (data) {
            this.anthropicApiKey = data || '';
        } else if (error) {
            console.error('Error loading Anthropic API key:', error);
        }
    }

    // Wire the available models from Apex
    @wire(getAvailableModels)
    wiredModels({ error, data }) {
        if (data) {
            // Add OpenAI models from ChatGPTService
            this.modelOptions = [...data];
            
            // Add Anthropic models
            this.modelOptions.push(
                { label: 'Claude Opus 4', value: 'claude-opus-4-20250514', provider: 'Anthropic' },
                { label: 'Claude Sonnet 4', value: 'claude-sonnet-4-20250514', provider: 'Anthropic' },
                { label: 'Claude Sonnet 3.7', value: 'claude-3-7-sonnet-20250219', provider: 'Anthropic' }
            );
            
            // Set default model if available
            if (data.length > 0) {
                this.selectedModel = data[0].value;
            }
        } else if (error) {
            console.error('Error loading models:', error);
            this.showToast('Error', 'Failed to load available models', 'error');
        }
    }

    // Computed property to disable send button
    get isSendDisabled() {
        return this.isLoading || !this.userInput.trim() || (this.isAnthropicModel && !this.anthropicApiKey);
    }

    // Handle model selection change
    handleModelChange(event) {
        this.selectedModel = event.detail.value;
    }

    // Handle temperature slider change
    handleTemperatureChange(event) {
        this.temperature = parseFloat(event.detail.value);
    }

    // Handle input field change
    handleInputChange(event) {
        this.userInput = event.detail.value;
    }

    // Handle key press (Enter to send, Shift+Enter for new line)
    handleKeyDown(event) {
        if (event.key === 'Enter' && !event.shiftKey) {
            event.preventDefault();
            this.handleSend();
        }
    }

    // Handle clear chat button
    handleClearChat() {
        this.messages = [];
        this.userInput = '';
        this.showToast('Success', 'Chat history cleared', 'success');
    }

    // Determine if the selected model is an Anthropic model
    get isAnthropicModel() {
        return this.selectedModel.startsWith('claude-');
    }

    // Handle send button click
    async handleSend() {
        if (this.isSendDisabled) return;

        const userMessage = this.userInput.trim();
        if (!userMessage) return;

        // Add user message to chat
        this.addMessage('user', userMessage);
        
        // Clear input
        this.userInput = '';
        
        // Add loading message for AI response
        const loadingMessageId = this.addLoadingMessage();

        try {
            let response;
            
            // Call the appropriate API based on the selected model
            if (this.isAnthropicModel) {
                // Call Anthropic API
                response = await getAnthropicResponse({
                    model: this.selectedModel,
                    prompt: userMessage,
                    temperature: this.temperature,
                    apiKey: this.anthropicApiKey
                });
            } else {
                // Call OpenAI API via ChatGPTService
                response = await getAIResponse({
                    userMessage: userMessage,
                    model: this.selectedModel,
                    temperature: this.temperature
                });
            }
            
            // Update the loading message with the actual response
            this.updateMessage(loadingMessageId, 'assistant', response);
        } catch (error) {
            console.error('Error calling AI service:', error);
            this.updateMessage(loadingMessageId, 'assistant', 'Sorry, I encountered an error. Please try again.');
            this.showToast('Error', 'Failed to get response from AI service', 'error');
        }
    }

    // Add a new message to the chat
    addMessage(role, content) {
        const message = {
            id: Date.now() + Math.random(),
            role: role === 'user' ? 'You' : 'Assistant',
            content: content,
            timestamp: new Date().toLocaleTimeString(),
            iconName: role === 'user' ? 'standard:user' : 'standard:bot',
            messageClass: `message ${role}-message`,
            isLoading: false
        };
        
        this.messages = [...this.messages, message];
        this.scrollToBottom();
    }

    // Add a loading message
    addLoadingMessage() {
        const messageId = Date.now() + Math.random();
        const message = {
            id: messageId,
            role: 'Assistant',
            content: '',
            timestamp: new Date().toLocaleTimeString(),
            iconName: 'standard:bot',
            messageClass: 'message assistant-message',
            isLoading: true
        };
        
        this.messages = [...this.messages, message];
        this.scrollToBottom();
        return messageId;
    }

    // Update an existing message
    updateMessage(messageId, role, content) {
        this.messages = this.messages.map(message => {
            if (message.id === messageId) {
                return {
                    ...message,
                    content: content,
                    isLoading: false
                };
            }
            return message;
        });
        this.scrollToBottom();
    }

    // Scroll to bottom of chat
    scrollToBottom() {
        setTimeout(() => {
            const chatMessages = this.template.querySelector('.chat-messages');
            if (chatMessages) {
                chatMessages.scrollTop = chatMessages.scrollHeight;
            }
        }, 100);
    }

    // Show toast notification
    showToast(title, message, variant) {
        const evt = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant
        });
        this.dispatchEvent(evt);
    }
} 