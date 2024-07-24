// hooks.js
let Hooks = {};

Hooks.AutoScroll = {
  mounted() {
    this.scrollToBottom();
  },
  updated() {
    this.scrollToBottom();
  },
  scrollToBottom() {
    const messageContainer = this.el;
    messageContainer.scrollTop = messageContainer.scrollHeight;
  },
};

export default Hooks;
