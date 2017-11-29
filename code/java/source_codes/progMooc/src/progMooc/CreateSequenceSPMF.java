package progMooc;
import java.io.BufferedReader;
import java.io.File;
import java.io.FileReader;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.HashMap;
import java.util.Map;


public class CreateSequenceSPMF {

	
	 public static void main(String[] args) {
		 	int countNoPattern = 0;
		    Map<String,Integer> map = new HashMap<String,Integer>();
		    map.put("b", 1);
	        map.put("B", 2);
	        map.put("r", 3);
	        map.put("R", 4);
	        map.put("m", 5);
	        map.put("M", 6);
	        map.put("s", 7);
	        map.put("S", 8);

		    map.put("_b", 9);
	        map.put("_B", 10);
	        map.put("_r", 11);
	        map.put("_R", 12);
	        map.put("_m", 13);
	        map.put("_M", 14);
	        map.put("_s", 15);
	        map.put("_S", 16);

		    map.put("b_", 17);
	        map.put("B_", 18);
	        map.put("r_", 19);
	        map.put("R_", 20);
	        map.put("m_", 21);
	        map.put("M_", 22);
	        map.put("s_", 23);
	        map.put("S_", 24);
	        
			BufferedReader reader = null;
			 
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
					if (clmn[11].replaceAll("_", "").equals("") == false)
					{
						for (i = 0; i < clmn[11].length()-1 ; i++)
						{
							if (i == 0)
							{
								seq += map.get(""+clmn[11].charAt(0)+clmn[11].charAt(1));
								i++;
							}
							else if (i == (clmn[11].length()-2))
							{
								seq += map.get(""+clmn[11].charAt(i)+clmn[11].charAt(i+1));
								i++;								
							}
							else
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
				System.out.println("Number of cases with no pattern:"+countNoPattern);
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
