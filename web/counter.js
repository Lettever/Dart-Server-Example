async function getNumber() {
    const resultElement = document.getElementById('result');

    try {
        const response = await fetch('/api/number', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
            },
            body: JSON.stringify({ requestTime: new Date().toISOString() })
        });
        
        if (!response.ok) {
            throw new Error('Server error: ' + response.status);
        }
        
        const data = await response.json();
        console.log(data);
        resultElement.innerText = 'Your number: ' + data.number;
    } catch (error) {
        resultElement.innerText = 'Error: ' + error.message;
        console.error('Error:', error);
    }
}