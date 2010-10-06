using Gee;

namespace Peg 
{
  public class Parser
  {
    public Gee.List<Token> stream;
    public ArrayList<MatchTree> backstep;
    public ArrayList<TreeMap<ParserElement, MatchTree>> packrat;
    public int position;
    public int indent;
    public bool debug;
    
    private void prepare(Gee.List<Token> stream) {
      this.stream = stream;
      this.position = 0;
      this.indent = 0;
      this.debug = false;
      // backstep = new ArrayList<MatchTree>(); // not used for now...
      packrat = new ArrayList<TreeMap<ParserElement, MatchTree>>();
      for(int i=0; i<stream.size; ++i)
          packrat.add(new TreeMap<ParserElement, MatchTree>());
    }
    
    public MatchTree? parse_stream(Gee.List<Token> stream, ParserElement root) {
      prepare(stream);
      return root.parse(this);
    }
    
    public MatchTree? parse_string(string str, ParserElement root) {
      var token_stream = new ArrayList<UToken>();
      for(int i = 0; i<str.length; ++i)
        token_stream.add(new UToken(str[i]));
      return parse_stream(token_stream, root);
    }
    
    public Token token() {
      return position < stream.size ? stream[position] : Token.get_eof();
    }
    
    public MatchTree? cached(ParserElement element) {
      if( debug && element.trace ) {
        stderr.printf(" got cached %s\n", (packrat[position][element] != null).to_string());
        --indent;
      }
      return packrat[position][element];
    }
    
    public bool speedup(ParserElement element) {
      if( debug && element.trace ) {
        for(int i = 0; i< indent; ++i) stderr.putc(' ');
        stderr.printf("Matching %s at %d...", element.name, position);
        ++indent;
      }
      bool ret = (position < packrat.size) && (element in packrat[position]);
      if(debug && element.trace && !ret) {
        stderr.putc('\n');
      } 
      return ret;
    }
    
    public void save(int position, ParserElement element, MatchTree? tree) {
      if( debug && element.trace ) {
        --indent;
        for(int i = 0; i< indent; ++i) stderr.putc(' ');
        if(tree == null) {
          stderr.printf("... matching %s at %d failed (%s).\n", element.name, position, token().to_string());
        } else {
          stderr.printf("... matching %s consumed %d-%d!\n", element.name, tree.position, tree.end);
        }
      }
      if(position < packrat.size) packrat[position][element] = tree;
    }
        
    public MatchTree? revert_cached(ParserElement elem) {
      MatchTree tree = packrat[position][elem];
      if(tree != null) position = tree.end;
      return tree;
    }
  }
}
