using Gee;

namespace Peg {
  public abstract class Browser {
    private Parser parser;
    
    public void browse(Parser parser, MatchTree tree) {
      this.parser = parser;      
      browse_without_parser(tree);
    }
    
    protected abstract void action(Parser parser, MatchTree node);

    private void browse_without_parser(MatchTree tree) {
      Object only = null;
      int non_nulls = 0;
      foreach(MatchTree subtree in tree.sub_matches) {
        browse_without_parser(subtree);
        if(subtree.data != null) {
          ++non_nulls;
          only = subtree.data;
        }
      }
      if(non_nulls == 1) {
        tree.data = only;             
      }
      action(parser, tree);          
    }
  }
}