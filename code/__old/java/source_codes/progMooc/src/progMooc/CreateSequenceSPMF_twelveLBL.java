package progMooc;
import java.io.BufferedReader;
import java.io.File;
import java.io.FileReader;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.HashMap;
import java.util.Map;


public class CreateSequenceSPMF_twelveLBL {

	
	 public static void main(String[] args) {
		 	int countNoPattern = 0;
		    Map<String,Integer> map = new HashMap<String,Integer>();
		    String[] list = new String[]{"_","a","b","c","d","e","f",
		    							 "g","h","i","j","k","l"};
		    int count = 0;
		    for (String s: list)
		    {
		    	map.put(s, ++count);
		    	if (s.equals("_") == false)
		    		map.put(s.toUpperCase(), ++count);
		    }
		    
			BufferedReader reader = null;
//			
//			String fname = "/Users/roya/Desktop/ProgMOOC/code/java/source_codes/progMooc/resource/BehavPatternExercise.txt";
//			String oname = "/Users/roya/Desktop/ProgMOOC/code/java/source_codes/progMooc/resource/t.txt";
			String fname = args[0];//TODO This is the full path to the file
			String oname = args[1];

			File input = new File(fname);
			File output = new File(oname);

			try {
				PrintWriter pw = new PrintWriter(output);
				
				reader = new BufferedReader(new FileReader(input));
				String line = null;
				String[] clmn;
				String cvsSplitBy = ",";//TODO very important, check input format
				String seq, tmp;
				int i;
				// repeat until all lines is read
				while ((line = reader.readLine()) != null) {
					clmn = line.split(cvsSplitBy);
					seq = "";
					if ((clmn[11].replaceAll("_", "").equals("") == false) &&
						 clmn[11].replaceAll("_", "").length() > 1) // we do not consider empty sequences or sequences with length 1
					{
						for (i = 0; i < clmn[11].length() ; i++)
						{
							seq += map.get(""+clmn[11].charAt(i));
							seq += " "; //space is used to separate the tokens in sequence
							seq += "-1"; //space is used in spam algorithm to separate items sets
							seq += " "; //space is used to separate the tokens in sequence
						}
						seq += "-2"; //it is used to separate the sequences
						pw.println(seq);

					}else{
						countNoPattern++;
					}
				}
				pw.close();
				System.out.println("Number of cases with pattern of length 0 or 1:"+countNoPattern);
			} catch (IOException e) {
				e.printStackTrace();
			} finally {
				try {
					if (reader != null) {
						reader.close();
					}
				} catch (IOException e) {
					e.printStackTrace();
				}
			}

		}

}
