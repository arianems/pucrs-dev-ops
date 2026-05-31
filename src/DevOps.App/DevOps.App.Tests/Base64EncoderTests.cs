using DevOps.App.Services;

namespace DevOps.App.Tests
{
    public class Base64EncoderTests
    {
        private Base64Encoder encoder;

        [SetUp]
        public void Setup()
        {
            encoder = new Base64Encoder();
        }

        [Test]
        public void Decode_WhenEncodedTextIsNullOrEmptyOrWhitespace_ThrowsArgumentNullException()
        {
            // Arrange, Act & Assert
            Assert.Throws<ArgumentNullException>(() => encoder.Decode(null));
            Assert.Throws<ArgumentNullException>(() => encoder.Decode(string.Empty));
            Assert.Throws<ArgumentNullException>(() => encoder.Decode(" "));
        }

        [Test]
        public void Decode_WhenEncodedTextIsInBase64_ReturnsDecodedValue()
        {
            // Arrange
            var encodedValue = "SGVsbG8sIHdvcmxkIQ==";
            var expectedValue = "Hello, world!";
            
            // Act
            var actualValue = encoder.Decode(encodedValue);

            // Assert
            Assert.That(actualValue, Is.EqualTo(expectedValue));
        }

        [Test]
        public void Decode_WhenEncodedTextIsNotInBase64_ThrowsInvalidOperationException()
        {
            // Arrange
            var plainText = "Hello, world!";

            // Act & Assert
            Assert.Throws<InvalidOperationException>(() => encoder.Decode(plainText));
        }

        [Test]
        public void Encode_WhenPlainTextIsNullOrEmptyOrWhitespace_ReturnsEmptyString()
        {

            using (Assert.EnterMultipleScope())
            {
                // Assert
                Assert.That(encoder.Encode(" "), Is.EqualTo(string.Empty));
                Assert.That(encoder.Encode(null), Is.EqualTo(string.Empty));
                Assert.That(encoder.Encode(string.Empty), Is.EqualTo(string.Empty));
            }
        }

        [Test]
        public void Encode_WhenPlainTextIsNotNullOrEmptyOrWhitespace_ReturnsEncodedValue()
        {
            // Arrange
            var plainText = "Hello, world!";
            var expectedValue = "SGVsbG8sIHdvcmxkIQ==";

            // Act
            var actualValue = encoder.Encode(plainText);

            // Assert
            Assert.That(actualValue, Is.EqualTo(expectedValue));
        }
    }
}
