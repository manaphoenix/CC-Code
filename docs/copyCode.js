function copyCode(button) {
    const codeBlock = button.parentElement.nextElementSibling;
    const code = codeBlock.textContent;

    navigator.clipboard.writeText(code).then(() => {
        button.textContent = "Copied!";
        setTimeout(() => {
            button.textContent = "Copy";
        }, 2000);
    });
}

function copyInstallationCode(button) {
    // Get the text to copy
    const textToCopy = button.previousElementSibling.textContent.trim();

    // Create a temporary textarea element to hold the text
    const textarea = document.createElement("textarea");
    textarea.value = textToCopy;
    document.body.appendChild(textarea);

    // Select the text and copy it to the clipboard
    textarea.select();
    document.execCommand("copy");

    // Remove the textarea from the DOM
    document.body.removeChild(textarea);

    // Change the span text to indicate success
    const buttonText = button.querySelector("span");
    buttonText.textContent = "Copied!";

    // Optionally, you can add feedback for the user
    button.classList.add("active");

    // Reset button text and remove active class after a delay
    setTimeout(() => {
        buttonText.textContent = "Copy"; // Reset text
        button.classList.remove("active"); // Remove active class
    }, 2000); // Adjust the duration as needed
}