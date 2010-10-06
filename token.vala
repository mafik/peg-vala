namespace Peg 
{
  public abstract class Token
  {
    public abstract string to_string();
    public abstract bool eof();
    public abstract bool compare(Token other);
    
    private static EOFToken _EOF = null;
    public static Token get_eof() {
      if(_EOF == null) _EOF = new EOFToken();
      return _EOF;
    }
  }
  
  public class EOFToken : Token
  {
    public override bool compare(Token other) {
      return other.eof();
    }
    
    public override string to_string() {
      return "";
    }
    
    public override bool eof() {
      return true;
    }
  }
  
  public class UToken : Token
  {
    private unichar _character;
    public unichar character {
      get { return _character; }
    }
    public UToken(unichar _c) {
      _character = _c;
    }
    
    public override bool compare(Token other) {
      return (other as UToken).character == character;
    }
    
    public override string to_string() {
      return _character.to_string();
    }
    
    public override bool eof() {
      return (int)_character == 0;
    }
  }
}