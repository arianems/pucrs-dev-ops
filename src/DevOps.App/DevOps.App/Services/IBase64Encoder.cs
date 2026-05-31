namespace DevOps.App.Services;

public interface IBase64Encoder
{
    public string Encode(string? plainText);

    public string Decode(string? encodedText);
}
