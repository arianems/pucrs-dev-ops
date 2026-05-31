using System.Text;

namespace DevOps.App.Services;

public class Base64Encoder : IBase64Encoder
{
    public string Decode(string? encodedText)
    {
        try
        {
            if (string.IsNullOrWhiteSpace(encodedText))
            {
                throw new ArgumentNullException(nameof(encodedText));
            }
            
            var bytes = Convert.FromBase64String(encodedText);
            return Encoding.UTF8.GetString(bytes);
        }
        catch (ArgumentNullException)
        {
            throw;
        }
        catch (Exception ex)
        {
            throw new InvalidOperationException($"Value could not be decoded. Value: {encodedText}", ex);
        }
    }

    public string Encode(string? plainText)
    {
        if (string.IsNullOrWhiteSpace(plainText))
        {
            return string.Empty;
        }

        var bytes = Encoding.UTF8.GetBytes(plainText);
        return Convert.ToBase64String(bytes);
    }
}
