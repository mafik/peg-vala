using Gee;

namespace Peg 
{
  public class Main
  {
    public static int main (string[] args)
    {
      try {
        var generator = new Generator();
        generator.load_peg_file("grammar.peg");
        var words = generator.get_rule("words");
        
        stdout.printf("start!\n");
        var parser = new Parser();
        var tree = parser.parse_string("mi klama la paris", words);
        stdout.printf("stop!\n");
      } catch(Error e) {
        stderr.printf("There was an input error...\n");
        return 1;
      }
      return 0;
    }
  }
}
