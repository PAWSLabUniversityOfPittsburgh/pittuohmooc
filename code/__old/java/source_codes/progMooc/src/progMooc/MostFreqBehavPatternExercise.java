package progMooc;
import java.io.BufferedReader;
import java.io.File;
import java.io.FileReader;
import java.io.FileWriter;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Map;
import java.util.regex.Matcher;
import java.util.regex.Pattern;
public class MostFreqBehavPatternExercise {
	
	private static ArrayList<String> freqPatternList;
	static Map<String,Integer> labelMap = new HashMap<String,Integer>();

	public static void main(String[] args) {
		
	    String[] listLbl = new String[]{"_","a","b","c","d","e","f",
				"g","h","i","j","k","l"};
	    int count = 0;
	    for (String s: listLbl)
	    {
	    			labelMap.put(s, ++count);
	    			if (s.equals("_") == false)
	    				labelMap.put(s.toUpperCase(), ++count);
	    }	


		BufferedReader br = null;
		String line = "";
		String[] clmn;

		try {
			String cvsSplitBy = ",";//TODO very important, check input format
			boolean isHeader = false;//TODO very important, check input format			
//			String data = args[0];//TODO This is the full path to the file
//			String destF = args[1];
			String mostFreqPatternsFile = "/Users/roya/Desktop/ProgMOOC/code/java/source_codes/progMooc/resource/OutputSPMFProcessed.txt";//TODO This is the full path to the file
			String data = "/Users/roya/Desktop/ProgMOOC/code/java/source_codes/progMooc/resource/BehavPatternExercise.txt";//TODO This is the full path to the file
			String destF = "/Users/roya/Desktop/ProgMOOC/code/java/source_codes/progMooc/resource/ClusteringInputMostFrequentPattern.txt";

			MostFreqBehavPatternExercise.readMostFrequentPattern(mostFreqPatternsFile);
			File file =new File(destF);
			if (!file.getParentFile().exists())
				file.getParentFile().mkdirs();
			if (!file.exists()){
	    		file.createNewFile();
	    	}
 	    	PrintWriter pw = new PrintWriter(new FileWriter(file, false));			
 	    	File input = new File(data);
 	    	if (!input.exists())
 	    		return;
 	    	br = new BufferedReader(new FileReader(data));

 	      // Create a Pattern object
 	    	String header = "";
 	    	for (String s : freqPatternList)
 	    		header = header + "," + s;
 	    	
    	    pw.println("dataset,user,exercise,pattern,avg.correct,noattempt"+header);

			while ((line = br.readLine()) != null) {
				if (isHeader)
				{
					isHeader = false;
					continue;
				}
			/*
				INPUT FORMAT
				s2014-ohpe,e32a8f9a539751f3179722e96bd244d5,viikko2-Viikko2_030.MihinJaMista,3,0,0,2,146,0,0,394,_SSBbB_,0.0,5.0	
	        */		
				clmn = line.split(cvsSplitBy);	
				String txt = clmn[0]+","+clmn[1]+","+clmn[2]+","+clmn[11]+","+clmn[12]+","+clmn[13]+",";
				for (String s : freqPatternList){
					Pattern pattern = Pattern.compile(s); //parenthesis is special character 
		    	    Matcher matcher = pattern.matcher(clmn[11]);
					int match = 0;
		    	    while (matcher.find()) 
						match++;
					txt = txt + match +",";
				}
				txt = txt.substring(0,txt.length()-1); //to drop comma at the end
				pw.println(txt);
			}
			br.close();	
			pw.close();			
		} catch (IOException e) {
			e.printStackTrace();
		} finally {			
			if (br != null) {
				try {
					br.close();
				} catch (IOException e) {
					e.printStackTrace();
				}
			}
		}		
	}

	private static void readMostFrequentPattern(String path) {
		freqPatternList = new ArrayList<String>();
		BufferedReader br = null;
		try{
			br = new BufferedReader(new FileReader(path));
			String line = null;
			String[] clmn;
			while ((line = br.readLine()) != null) {
				clmn = line.split("\t"); //format is:_(II)(tab)_A(tab)#cases: 42483 out of 94101 (45.15%)
				if (clmn[1].replaceAll("_", "").length() > 1) //if frePattern has length greater than 1
					freqPatternList.add(clmn[1]);
			}
			br.close();	
		}catch (IOException e) {
			e.printStackTrace();
		} finally {			
			if (br != null) {
				try {
					br.close();
				} catch (IOException e) {
					e.printStackTrace();
				}
			}
		}		
		
	}
}
