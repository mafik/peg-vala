using Gee;

namespace Peg
{
  public abstract class ParserExpression : ParserElement
  {
    public ArrayList<ParserElement> sub_elements;
    
    construct {
      sub_elements = new ArrayList<ParserElement>();
    }
    
    // convenience funcs
    public override ParserElement add(ParserElement elem) {
      sub_elements.add(elem);
      return this;
    }
    
    // string output funcs
    protected abstract string get_vala_name();
    
    public override string to_string_vala() {
      string str = "new ";
      str += get_vala_name();
      str += "()";
      for(int i = 0; i<sub_elements.size;++i) {
        str += ".add(";
        if(sub_elements[i].has_name) {
          str += sub_elements[i].name;
        } else {
          str += sub_elements[i].to_string_vala();
        }
        str += ")";
      }
      if(has_name) {
        string n = this.name;
        str += @".with_name(\"$n\")";
      }
      return str;
    }
  }

  public class And : ParserExpression {
    public override MatchTree? parse(Parser parser) {
      if(parser.speedup(this)) return parser.revert_cached(this);
      int position = parser.position;
      MatchTree tree = make_tree(position);
      foreach(ParserElement e in sub_elements) {
        MatchTree subtree = e.parse(parser);
        if(subtree == null) {
          parser.position = position;
          return fail(parser, position);
        }
        tree.add(subtree);
      }
      tree.end = parser.position;
      return match(parser, tree);
    }
    
    protected override string get_vala_name() {
      return "And";
    }
    
    public override string to_string_peg() {
      string str = "(";
      for(int i = 0; i<sub_elements.size;++i) {
        if(i > 0) {
          str += " ";
        }
        if(sub_elements[i].has_name) {
          str += sub_elements[i].name;
        } else {
          str += sub_elements[i].to_string_peg();
        }
      }
      str += ")";
      return str;
    }
  }

  public class Or_ : ParserExpression {
    public override MatchTree? parse(Parser parser) {
      if(parser.speedup(this)) return parser.revert_cached(this);
      int position = parser.position;
      MatchTree tree = make_tree(position);
      foreach(ParserElement e in sub_elements) {
        MatchTree subtree = e.parse(parser);
        if(subtree != null) {
          tree.add(subtree);
          tree.end = parser.position;
          return match(parser, tree);
        }
        parser.position = position;
      }
      return fail(parser, position);
    }
    
    protected override string get_vala_name() {
      return "Or_";
    }
    
    public override string to_string_peg() {
      string str = "(";
      for(int i = 0; i<sub_elements.size;++i) {
        if(i > 0) {
          str += " / ";
        }
        if(sub_elements[i].has_name) {
          str += sub_elements[i].name;
        } else {
          str += sub_elements[i].to_string_peg();
        }
      }
      str += ")";
      return str;
    }
  }

  public class Optional : ParserExpression {
    public override MatchTree? parse(Parser parser) {
      if(parser.speedup(this)) return parser.revert_cached(this);
      assert(sub_elements.size == 1);
      int position = parser.position;
      MatchTree tree = make_tree(position); 
      MatchTree subtree = sub_elements[0].parse(parser);
      if(subtree != null) { 
        tree.add(subtree);
        tree.end = parser.position;
      } else {
        parser.position = position;
      }
      return match(parser, tree);
    }
    
    protected override string get_vala_name() {
      return "Optional";
    }
    
    public override string to_string_peg() {
      string str = "";
      if(sub_elements[0].has_name) {
        str += sub_elements[0].name;
      } else {
        str += sub_elements[0].to_string_peg();
      }
      str += "?";
      return str;
    }
  }

  public class ZeroOrMore : ParserExpression {
    public override MatchTree? parse(Parser parser) {
      if(parser.speedup(this)) return parser.revert_cached(this);
      assert(sub_elements.size == 1);
      int position = parser.position;
      MatchTree tree = make_tree(position);
      MatchTree subtree = sub_elements[0].parse(parser); 
      while(subtree != null) {
        tree.add(subtree);
        subtree = sub_elements[0].parse(parser);
      }
      tree.end = parser.position;
      return match(parser, tree);
    }
    
    protected override string get_vala_name() {
      return "ZeroOrMore";
    }
    
    public override string to_string_peg() {
      string str = "";
      if(sub_elements[0].has_name) {
        str += sub_elements[0].name;
      } else {
        str += sub_elements[0].to_string_peg();
      }
      str += "*";
      return str;
    }
  }

  public class OneOrMore : ParserExpression {
    public override MatchTree? parse(Parser parser) {
      if(parser.speedup(this)) return parser.revert_cached(this);
      assert(sub_elements.size == 1);
      int position = parser.position;
      MatchTree tree = make_tree(position);
      MatchTree subtree = sub_elements[0].parse(parser);
      if(subtree == null) {
        parser.position = position;
        return fail(parser, position);
      } 
      do {
        tree.add(subtree);
        subtree = sub_elements[0].parse(parser);
      } while(subtree != null);
      tree.end = parser.position;
      return match(parser, tree);
    }
    
    protected override string get_vala_name() {
      return "OneOrMore";
    }
    
    public override string to_string_peg() {
      string str = "";
      if(sub_elements[0].has_name) {
        str += sub_elements[0].name;
      } else {
        str += sub_elements[0].to_string_peg();
      }
      str += "+";
      return str;
    }
  }

  public class Follow : ParserExpression {
    public override MatchTree? parse(Parser parser) {
      if(parser.speedup(this)) return parser.revert_cached(this);
      assert(sub_elements.size == 1);
      int position = parser.position;
      MatchTree tree = make_tree(position);
      MatchTree subtree = sub_elements[0].parse(parser);
      if(subtree == null) {
        parser.position = position;
        return fail(parser, position);
      }
      tree.add(subtree);
      tree.end = parser.position;
      parser.position = position;
      return match(parser, tree);
    }
    
    protected override string get_vala_name() {
      return "Follow";
    }
    
    public override string to_string_peg() {
      string str = "&";
      if(sub_elements[0].has_name) {
        str += sub_elements[0].name;
      } else {
        str += sub_elements[0].to_string_peg();
      }
      return str;
    }
  }

  public class Not : ParserExpression {
    public override MatchTree? parse(Parser parser) {
      if(parser.speedup(this)) return parser.revert_cached(this);
      assert(sub_elements.size == 1);
      int position = parser.position;
      MatchTree tree = make_tree(position);
      MatchTree subtree = sub_elements[0].parse(parser);
      parser.position = position;
      if(subtree == null) {
        return match(parser, tree);
      }
      return fail(parser, position);
    }
    
    protected override string get_vala_name() {
      return "Not";
    }
    
    public override string to_string_peg() {
      string str = "!";
      if(sub_elements[0].has_name) {
        str += sub_elements[0].name;
      } else {
        str += sub_elements[0].to_string_peg();
      }
      return str;
    }
  }

  public class Forward : ParserExpression {
    public override MatchTree? parse(Parser parser) {
      if(parser.speedup(this)) return parser.revert_cached(this);
      string name = this.name;
      assert(sub_elements.size == 1);
      int position = parser.position;
      MatchTree subtree = sub_elements[0].parse(parser);
      if(subtree == null)
        return fail(parser, position);
      return match(parser, subtree);
    }
    
    protected override string get_vala_name() {
      return "Forward";
    }
    
    public override string to_string_peg() {
      string str = "(";
      if(sub_elements[0].has_name) {
        str += sub_elements[0].name;
      } else {
        str += sub_elements[0].to_string_peg();
      }
      str += ")";
      return str;
    }
  }
}
