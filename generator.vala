using Gee;

namespace Peg {
  
  public class Generator : Browser {

    private And grammar;
    private And definition;
    private And expression;
    private ZeroOrMore sequence;
    private And prefix;
    private And suffix;
    private Or_ primary;
    private And identifer;
    private Or_ ident_start;
    private Or_ ident_cont;
    private Or_ literal;
    private And class_;
    private Or_ range;
    private Or_ char_;
    private And LEFT_ARROW;
    private And SLASH;
    private And AND;
    private And NOT;
    private And QUERY;
    private And STAR;
    private And PLUS;
    private And OPEN;
    private And CLOSE;
    private And DOT;
    private ZeroOrMore spacing;
    private And comment;
    private Or_ space;
    private Or_ end_of_line;
    private EndOfFile end_of_file;
    
    public Generator() {
      grammar = new And();
      definition = new And();
      expression = new And();
      sequence = new ZeroOrMore();
      prefix = new And();
      suffix = new And();
      primary = new Or_();
      identifer = new And();
      ident_start = new Or_();
      ident_cont = new Or_();
      literal = new Or_();
      class_ = new And();
      range = new Or_();
      char_ = new Or_();
      LEFT_ARROW = new And();
      SLASH = new And();
      AND = new And();
      NOT = new And();
      QUERY = new And();
      STAR = new And();
      PLUS = new And();
      OPEN = new And();
      CLOSE = new And();
      DOT = new And();
      spacing = new ZeroOrMore();
      comment = new And();
      space = new Or_();
      end_of_line = new Or_();
      end_of_file = new EndOfFile();
      
      grammar.add(spacing).add(new OneOrMore().add(definition)).add(end_of_file).with_debug().name = "grammar";
      definition.add(identifer).add(LEFT_ARROW).add(expression).with_debug().name = "definition";
      expression.add(sequence).add(new ZeroOrMore().add(new And().add(SLASH).add(sequence))).with_debug().name = "expression";
      sequence.add(prefix).with_debug().name = "sequence";
      prefix.add(new Optional().add(new Or_().add(AND).add(NOT))).add(suffix).with_debug().name = "prefix";
      suffix.add(primary).add(new Optional().add(new Or_().add(QUERY).add(STAR).add(PLUS))).with_debug().name = "suffix";
      primary.add(new And().add(identifer).add(new Not().add(LEFT_ARROW)))
             .add(new And().add(OPEN).add(expression).add(CLOSE))
             .add(literal)
             .add(class_)
             .add(DOT).with_debug().name = "primary";
      identifer.add(ident_start).add(new ZeroOrMore().add(ident_cont)).add(spacing).with_debug().name = "identifier";
      
      var apos = new ULiteral('\'');
      var quot = new ULiteral('"');
      var send = new ULiteral(']');
      var minus = new ULiteral('-');
      var comma = new ULiteral(',');
      var dot = new ULiteral('.');
      var backspace = new ULiteral('\\');
      var exclamation = new ULiteral('!');
      var question = new ULiteral('?');
      var myspace = new ULiteral(' ');
      
      ident_start.add(new ULetter()).add(new ULiteral('_')).name = "ident_start";
      ident_cont.add(ident_start).add(new UDigit()).add(minus).name = "ident_cont";
      literal.add(new And().add(apos).add(new ZeroOrMore().add( new And().add(new Not().add(apos)).add(char_) )).add(apos).add(spacing))
             .add(new And().add(quot).add(new ZeroOrMore().add( new And().add(new Not().add(quot)).add(char_) )).add(quot).add(spacing)).with_debug().name = "literal";
      class_.add(new ULiteral('[')).add(new ZeroOrMore().add( new And().add(new Not().add(send)).add(range) )).add(send).add(spacing).with_debug().name = "class_";
      range.add(new And().add(char_).add(minus).add(char_)).add(char_).with_debug().name = "range";
      var escaped = new And().add(backspace).add(new Or_().add(new ULiteral('t')).add(new ULiteral('n')).add(new ULiteral('r'))).with_name("escaped");
      var simple_char = new Or_()
        .add(new ULetter()).add(new UDigit())
        .add(comma).add(apos).add(exclamation).add(question)
        .add(myspace).with_name("simple_char");
      char_.add(simple_char).add(escaped).add(dot).with_debug().name = "char_";
      LEFT_ARROW.add(new ULiteral('<')).add(new ULiteral('-')).add(spacing).with_debug().name = "LEFT_ARROW";
      SLASH.add(new ULiteral('/')).add(spacing).with_debug().name = "SLASH";
      AND.add(new ULiteral('&')).add(spacing).with_debug().name = "AND";
      NOT.add(exclamation).add(spacing).with_debug().name = "NOT";
      QUERY.add(question).add(spacing).with_debug().name = "QUERY";
      STAR.add(new ULiteral('*')).add(spacing).with_debug().name = "STAR";
      PLUS.add(new ULiteral('+')).add(spacing).with_debug().name = "PLUS";
      OPEN.add(new ULiteral('(')).add(spacing).with_debug().name = "OPEN";
      CLOSE.add(new ULiteral(')')).add(spacing).with_debug().name = "CLOSE";
      DOT.add(dot).add(spacing).with_debug().name = "DOT";
      spacing.add(new Or_().add(space).add(comment));
      var any_char = new Any();
      var comment_begin = new Or_().add(new ULiteral(';')).add(new ULiteral('#')).with_debug();
      comment_begin.name = "comment_begin";
      var comment_body = new ZeroOrMore().add(new And().add(new Not().add(end_of_line)).add(any_char)).with_debug();
      comment_body.name = "comment_body";
      comment.add(comment_begin).add(comment_body).add(end_of_line).with_debug().name = "comment";
      space.add(myspace).add(new ULiteral('\t')).add(end_of_line);
      end_of_line.add(new ULiteral('\n')).add(new ULiteral('\r')).with_debug().name = "eol";
      end_of_file.with_debug().name = "end_of_file";
      loaded = new HashMap<string, ParserExpression>();
    }
      
    public override void action(Parser parser, MatchTree tree) {
      switch(tree.element.name) {
      case "literal":
        int begin = tree.position;
        int end = tree.end;
        string name = "";
        foreach(var token in parser.stream[begin:end])
          name += token.to_string();
        stderr.printf("Parser error: literal unimplemented \"%s\" %d-%d\n", name, begin, end);
        break;
      case "class_":
        MatchTree ranges = tree.sub_matches[1];
        
        int begin = ranges.position-1;
        int end = ranges.end+1;
        string name = "";
        foreach(var token in parser.stream[begin:end])
          name += token.to_string();
        tree.data = new URegex(name);
        break;
      case "identifier":
        int begin = tree.position;
        int end = tree.sub_matches[1].end;
        string name = "";
        foreach(var token in parser.stream[begin:end]) {
          name += token.to_string();
        }
        if(!(name in loaded)) {
          loaded[name] = new Forward();
          loaded[name].name = name;
        }
        tree.data = loaded[name];
        break;
      case "definition":
        ParserElement? rule = tree.sub_matches[0].data as ParserElement;
        ParserElement? logic = tree.sub_matches[2].data as ParserElement;
        if(logic != null) {
          rule.add(logic);
        } else if(parser.debug) {
          stderr.printf("Parsing error: expression didn't returned value at %d-%d\n",
            tree.sub_matches[2].position, 
            tree.sub_matches[2].end);
        }
        break;
      case "expression":
        var tail = tree.sub_matches[1]; 
        if(tail.sub_matches.size > 0) {
          var r = new Or_();
          ParserElement? e = tree.sub_matches[0].data as ParserElement;
          assert(e != null);
          r.add(e);
          foreach(var sub in tail.sub_matches) {
            e = sub.data as ParserElement; 
            assert(e != null);
            r.add(e);
          }
          tree.data = r;
        } else {
          assert(tree.sub_matches[0] != null);
          tree.data = tree.sub_matches[0].data;
        }
        break;
      case "sequence":
        if(tree.sub_matches.size > 1) {
          var r = new And();
          foreach(var sub in tree.sub_matches) {
            ParserElement? e = sub.data as ParserElement; 
            if(e != null) {
              r.add(e);
            } else if(parser.debug) {
              stderr.printf("Parsing error: prefix didn't returned value at %d-%d\n", sub.position, sub.end);
            }
          }
          tree.data = r;
        } else {
          tree.data = tree.sub_matches[0].data;
        }
        break;
      case "prefix":
        if(tree.sub_matches[0].data != null) {
          ParserElement? prefix = tree.sub_matches[0].data as ParserElement;
          ParserElement? term = tree.sub_matches[1].data as ParserElement; 
          if(term != null) {
            prefix.add(term);
          } else if(parser.debug) {
            stderr.printf("Parsing error: term of a prefix didn't returned value at %d-%d\n",
              tree.sub_matches[1].position,
              tree.sub_matches[1].end);
          }
          tree.data = prefix;
        } else {
          tree.data = tree.sub_matches[1].data;
        }
        break;
      case "suffix":
        if(tree.sub_matches[1].data != null) {
          ParserElement? suffix = tree.sub_matches[1].data as ParserElement;
          ParserElement? term = tree.sub_matches[0].data as ParserElement; 
          if(term != null) {
            suffix.add(term);
          } else if(parser.debug) {
            stderr.printf("Parsing error: term of a suffix didn't returned value at %d-%d\n",
              tree.sub_matches[0].position,
              tree.sub_matches[0].end);
          }
          tree.data = suffix;
        } else {
          tree.data = tree.sub_matches[0].data;
        }
        break;
      case "AND":
        tree.data = new Follow();
        break;
      case "NOT":
        tree.data = new Not();
        break;
      case "PLUS":
        tree.data = new OneOrMore();
        break;
      case "STAR":
        tree.data = new ZeroOrMore();
        break;
      case "QUERY":
        tree.data = new Optional();
        break;
      case "DOT":
        tree.data = new Any();
        break;
      }
    }
    
    HashMap<string, ParserExpression> loaded;
    
    public ParserExpression? get_rule(string name) {
      if(name in loaded) return loaded[name];
      return null;
    }
    
    public void load_peg_string(string peg_string) {
      Parser parser = new Parser();
      var tree = parser.parse_string(peg_string, grammar);
      browse(parser, tree);
    }
    
    public void load_peg_file(string path) throws Error, IOError {
      var file = File.new_for_path (path);

      if (!file.query_exists (null)) {
          throw new FileError.NFILE("File '$path' doesn't exist.");
      }

      var in_stream = new DataInputStream (file.read (null));
      var token_stream = new ArrayList<Token>();
      string line;
      while ((line = in_stream.read_line (null, null)) != null) {
        for(int i = 0; i<line.length; ++i)
          token_stream.add(new UToken(line[i]));
        token_stream.add(new UToken('\n'));
      }
          
      Parser parser = new Parser();
      var tree = parser.parse_stream(token_stream, grammar);
      browse(parser, tree);
    }
  }
}
