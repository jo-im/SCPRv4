function Resound() {
    this.domain = window.resoundStore.url;
    var that = this;
    window.addEventListener('message', function(ev) {
        if (!that.domain.match(ev.origin)) return;
        if (ev.data.type && ev.data.type === 'url') {
            var urlInput = document.getElementById('audioUrl');
            if (urlInput) {
                urlInput.value = ev.data.value;
            }
        }
    }, false);
}

Resound.prototype.open = function() {
    window.open(this.domain);
}
