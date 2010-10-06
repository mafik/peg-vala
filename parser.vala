using Gee;

namespace Peg 
{
  public class Parser
  {
    public Gee.List<Token> stream;
    public ArrayList<MatchTree> backstep;
    public HashTable<ParserElement, MatchTree>[] packrat;
    public int position;
    public int indent;
    public bool debug;
    
    private void prepare(Gee.List<Token> stream) {
      this.stream = stream;
      this.position = 0;
      this.indent = 0;
      this.debug = false;
      // backstep = new ArrayList<MatchTree>(); // not used for now...
      packrat = new HashTable<ParserElement, MatchTree>[stream.size];
      for(int i=0; i<stream.size; ++i)
          packrat[i] = new HashTable<ParserElement, MatchTree>(ParserElement.hash, ParserElement.eq);
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
    
    public unowned MatchTree? cached(ParserElement element) {
      if( debug && element.trace ) {
        stderr.printf(" got cached %s\n", packrat[position].lookup(element).to_string());
        --indent;
      }
      return packrat[position].lookup(element);
    }
    
    public bool speedup(ParserElement element) {
      if( debug && element.trace ) {
        for(int i = 0; i< indent; ++i) stderr.putc(' ');
        stderr.printf("Matching %s at %d...", element.name, position);
        ++indent;
      }
      ParserElement a;
      MatchTree b;
      bool ret = (position < packrat.length) && (packrat[position].lookup_extended(element, out a, out b));
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
      if(position < packrat.length) packrat[position].insert(element, tree);
    }
        
    public MatchTree? revert_cached(ParserElement elem) {
      MatchTree tree = packrat[position].lookup(elem);
      if(tree != null) position = tree.end;
      return tree;
    }
  }
}
