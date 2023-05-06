document.addEventListener('DOMContentLoaded', function() {
    // Add event listeners for user interactions
    // Integrate temperature conversion algorithms
});
function celsiusToFahrenheit(celsius) {
    return (celsius * 9/5) + 32;
}

function fahrenheitToCelsius(fahrenheit) {
    return (fahrenheit - 32) * 5/9;
}

function celsiusToKelvin(celsius) {
    return celsius + 273.15;
}

function kelvinToCelsius(kelvin) {
    return kelvin - 273.15;
}

function fahrenheitToKelvin(fahrenheit) {
    return (fahrenheit - 32) * 5/9 + 273.15;
}

function kelvinToFahrenheit(kelvin) {
    return (kelvin - 273.15) * 9/5 + 32;
}
document.getElementById('temperature-conversion-form').addEventListener('submit', function(event) {
    event.preventDefault();

    const inputTemperature = parseFloat(document.getElementById('input-temperature').value);
    const inputScale = document.getElementById('input-scale').value;
    const outputScale = document.getElementById('output-scale').value;

    let result;

    if (inputScale === 'celsius') {
        if (outputScale === 'fahrenheit') {
            result = celsiusToFahrenheit(inputTemperature);
        } else if (outputScale === 'kelvin') {
            result = celsiusToKelvin(inputTemperature);
        }
    } else if (inputScale === 'fahrenheit') {
        if (outputScale === 'celsius') {
            result = fahrenheitToCelsius(inputTemperature);
        } else if (outputScale === 'kelvin') {
            result = fahrenheitToKelvin(inputTemperature);
        }
    } else if (inputScale === 'kelvin') {
        if (outputScale === 'celsius') {
            result = kelvinToCelsius(inputTemperature);
        } else if (outputScale === 'fahrenheit') {
            result = kelvinToFahrenheit(inputTemperature);
        }
    }

    document.getElementById('conversion-result').textContent = 'Result: ' + result.toFixed(2) + ' ' + outputScale;
});