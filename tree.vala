using Gee;

namespace Peg
{
  public class MatchTree
  {
    public int position;
    public int end;
    public ParserElement element;
    public ArrayList<MatchTree> sub_matches;
    public Object data;
    
    public MatchTree(int position, int end, ParserElement element) {
      this.position = position;
      this.end = end;
      this.element = element;
      this.sub_matches = new ArrayList<MatchTree>();
      this.data = null;
    }
    
    public MatchTree add(MatchTree sub_match) {
      assert(sub_match.position >= position);
      sub_matches.add(sub_match);
      return this;
    }
    
    public string to_string() {
      return to_string_indent(0);
    }
    
    public string to_string_indent(int indent) {
      string str = "";
      if(indent > 0) {
        str += "+" + string.nfill(indent-1, '|');
      }
      str += @"node $position - $end\n";
      foreach(var sub in sub_matches) {
        str += sub.to_string_indent(indent+1);
      }
      return str;
    }
  }
}
