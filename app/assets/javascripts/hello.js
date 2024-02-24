function sendData() {
    var form = new FormData();
    form.append("message", "Hello from Turbo Streams!");

    fetch("/send_data", {
        method: "POST",
        body: form
    });
}