
namespace Peg
{
  public abstract class ParserElement : Object
  {
    public string name { get; set; default = ""; }
    public bool has_name { get { return name.length > 0; } }
    public bool trace { get; set; default = false; }
    
    private static int seq_counter = 0;
    private int seq;
    
    construct {
      seq = seq_counter++;
    }
    
    public abstract MatchTree? parse(Parser parser);
    
    public static uint hash(void* key) {
      weak ParserElement element = (ParserElement)key;
      return element.seq;
    }
    
    public static bool eq(void* a, void* b) {
      weak ParserElement A = (ParserElement)a;
      weak ParserElement B = (ParserElement)b;
      return A.seq == B.seq;
    } 
    
    // public convenience functions
    public ParserElement with_debug() {
      this.trace = true;
      return this;
    }
    public ParserElement with_name(string name) {
      this.name = name;
      return this;
    }
    public virtual ParserElement add(ParserElement elem) {
      stderr.printf("Adding sub-elements to element!");
      return this;
    }
    
    // parsing helper functions
    protected MatchTree match(Parser parser, MatchTree tree) {
      parser.save(tree.position, this, tree);
      return tree;
    }
    
    protected MatchTree? fail(Parser parser, int pos) {
      parser.save(pos, this, (MatchTree)null);
      return (MatchTree)null;
    }
    
    protected MatchTree make_tree(int position) {
      return new MatchTree(position, position, this);
    }
    
    // output functions
    public abstract string to_string_peg();
    public abstract string to_string_vala();
  }

  public class Any : ParserElement
  {
    public override MatchTree? parse(Parser parser) {
      if(parser.speedup(this)) return parser.revert_cached(this);
      int position = parser.position;
      if(!parser.token().eof()) {
        MatchTree tree = make_tree(position);
        parser.position += 1;
        tree.end = parser.position;
        return match(parser, tree);
      }
      return fail(parser, position);
    }
    
    public override string to_string_peg() {
      return ".";
    }
    
    public override string to_string_vala() {
      return "new Any()";
    }
  }

  public class URegex : ParserElement
  {
    public Regex regex;
    public string pattern;
    
    public URegex(string pattern) {
      try {
        this.regex = new Regex(pattern);
      } catch (RegexError err) {
        this.regex = new Regex("^never match this$");
      }
      this.pattern = pattern;
    }
    
    public override MatchTree? parse(Parser parser) {
      if(parser.speedup(this)) return parser.revert_cached(this);
      int position = parser.position;
      string str = parser.token().to_string(); 
      if(regex.match(str)) {
        MatchTree tree = make_tree(position);
        parser.position += 1;
        tree.end = parser.position;
        return match(parser, tree);
      }
      return fail(parser, position);
    }
    
    public override string to_string_peg() {
      return pattern;
    }
    
    public override string to_string_vala() {
      return @"new URegex(\"$pattern\")";
    }
  }

  public class Literal : ParserElement
  {
    public Token pattern { get; construct; }
    
    public Literal(Token pattern) {
      Object(pattern: pattern);
    }
    
    public override MatchTree? parse(Parser parser) {
      if(parser.speedup(this)) return parser.revert_cached(this);
      int position = parser.position;
      if(parser.token().compare(pattern)) {
        MatchTree tree = make_tree(position);
        parser.position += 1;
        tree.end = parser.position;
        return match(parser, tree);
      }
      return fail(parser, position);
    }
    
    public override string to_string_peg() {
      return pattern.to_string();
    }
    
    public override string to_string_vala() {
      return @"new Literal($pattern)";
    }
  }

  public class ULiteral : Literal
  {
    public ULiteral(unichar c) {
      Object(pattern: new UToken(c));
    }
    
    public override string to_string_peg() {
      return @"[$pattern]";
    }
    
    public override string to_string_vala() {
      return @"new ULiteral('$pattern')";
    }
  }

  public class ULetter : ParserElement
  {
    public override MatchTree? parse(Parser parser) {
      if(parser.speedup(this)) return parser.revert_cached(this);
      int position = parser.position;
      UToken t = parser.token() as UToken; 
      if(t != null && t.character.isalpha()) {
        MatchTree tree = make_tree(position);
        parser.position += 1;
        tree.end = parser.position;
        return match(parser, tree);
      }
      return fail(parser, position);
    }
    
    public override string to_string_peg() {
      return @"[a-zA-Z]";
    }
    
    public override string to_string_vala() {
      return @"new ULetter()";
    }
  }

  public class UDigit : ParserElement
  {
    public override MatchTree? parse(Parser parser) {
      if(parser.speedup(this)) return parser.revert_cached(this);
      int position = parser.position;
      UToken t = parser.token() as UToken; 
      if(t != null && t.character.isdigit()) {
        MatchTree tree = make_tree(position);
        parser.position += 1;
        tree.end = parser.position;
        return match(parser, tree);
      }
      return fail(parser, position);
    }
    
    public override string to_string_peg() {
      return @"[0-9]";
    }
    
    public override string to_string_vala() {
      return @"new UDigit()";
    }
  }

  public class EndOfFile : ParserElement
  {
    public override MatchTree? parse(Parser parser) {
      if(parser.speedup(this)) return parser.revert_cached(this);
      int position = parser.position;
      if(parser.token().eof())
        return match(parser, make_tree(position));
      return fail(parser, position);
    }
    
    public override string to_string_peg() {
      return @"!.";
    }
    
    public override string to_string_vala() {
      return @"new EndOfFile()";
    }
  }
}
