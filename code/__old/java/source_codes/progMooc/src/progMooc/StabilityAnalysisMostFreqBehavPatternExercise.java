package progMooc;
import java.io.BufferedReader;
import java.io.File;
import java.io.FileReader;
import java.io.FileWriter;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.ArrayList;
import java.util.Collections;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.regex.Matcher;
import java.util.regex.Pattern;
public class StabilityAnalysisMostFreqBehavPatternExercise {
	
	private static ArrayList<String> freqPatternList;
	static Map<String,Integer> labelMap = new HashMap<String,Integer>();
	static Map<String,ArrayList<String>> userSeqMap = new HashMap<String,ArrayList<String>>();
	static Map<String,ArrayList<String>> userSeqShuffledMap = new HashMap<String,ArrayList<String>>();

	static Map<String,ArrayList<Double[]>> userHalfVecSheffle = new HashMap<String,ArrayList<Double[]>>();
	static Map<String,ArrayList<Double[]>> userHalfVecEarlyLate = new HashMap<String,ArrayList<Double[]>>();

	public static void main(String[] args) {

		String[] listLbl = new String[] { "_", "a", "b", "c", "d", "e", "f",
										  "g", "h", "i", "j", "k", "l" };
		int count = 0;
		for (String s : listLbl) {
			labelMap.put(s, ++count);
			if (s.equals("_") == false)
				labelMap.put(s.toUpperCase(), ++count);
		}

		String mostFreqPatternsFile = "/Users/roya/Desktop/ProgMOOC/code/java/source_codes/progMooc/resource/OutputSPMFProcessed.txt";
		String data = "/Users/roya/Desktop/ProgMOOC/code/java/source_codes/progMooc/resource/BehavPatternExercise.txt";
		String destFEarlyLate = "/Users/roya/Desktop/ProgMOOC/code/java/source_codes/progMooc/resource/StanbilityAnalysisMostFrequentPattern_EarlyLate.txt";
		String destFRandom = "/Users/roya/Desktop/ProgMOOC/code/java/source_codes/progMooc/resource/StanbilityAnalysisMostFrequentPattern_Random.txt";
		String destFALL = "/Users/roya/Desktop/ProgMOOC/code/java/source_codes/progMooc/resource/StanbilityAnalysisMostFrequentPattern_ALL.txt";

		String destFRandomJS = "/Users/roya/Desktop/ProgMOOC/code/java/source_codes/progMooc/resource/StanbilityAnalysisMostFrequentPattern_RandomJS.txt";
		String destFEarlyLateJS = "/Users/roya/Desktop/ProgMOOC/code/java/source_codes/progMooc/resource/StanbilityAnalysisMostFrequentPattern_EarlyLateJS.txt";

		StabilityAnalysisMostFreqBehavPatternExercise.readMostFrequentPattern(mostFreqPatternsFile);
		StabilityAnalysisMostFreqBehavPatternExercise.readAllStudentSequences(data);
		// shuffle the sequences of each student
		for (String s : userSeqMap.keySet()) {
			ArrayList<String> shuffledList = new ArrayList<String>(userSeqMap.get(s));
			Collections.shuffle(shuffledList);
			userSeqShuffledMap.put(s, shuffledList);
		}
		
		//print number of users and sequences of each
//		List<String> filter = new ArrayList<String>();
//		for (String s : userSeqMap.keySet()){
//			if (userSeqMap.get(s).size() < 60)	//median is 93, genome threshold is 60
//				filter.add(s);
//		}
		//out of 1788 , 454 has less than 60 sequences, 1334 has 60 or more.
		
//		for (String s : filter){
//			userSeqMap.remove(s);
//			userSeqShuffledMap.remove(s);
//		}
		
		GenerateWriteFreqPatternsVectors(destFRandom, userSeqShuffledMap);
		GenerateWriteFreqPatternsVectors(destFEarlyLate, userSeqMap);
//		GenerateWriteFreqPatternsVectorsAll(destFALL,userSeqMap);
		readData(destFRandom,userHalfVecSheffle);
		readData(destFEarlyLate,userHalfVecEarlyLate);

		GenerateWriteJS(destFRandomJS, userHalfVecSheffle);
		GenerateWriteJS(destFEarlyLateJS, userHalfVecEarlyLate);
		

	}

	private static void GenerateWriteJS(String destF,Map<String, ArrayList<Double[]>> userHalfVecSheffle) {

		PrintWriter pw = null;
		try{
			pw = new PrintWriter(new FileWriter(destF, false));
			for (String s : userHalfVecSheffle.keySet()) {
				ArrayList<Double[]> sList = userHalfVecSheffle.get(s);
				double self_dist = jensenShannonDivergence(sList.get(0),sList.get(1));
				String txt = s+","+self_dist+",";
				for (String os : userHalfVecSheffle.keySet())
				{// distance with others
					if (s.equals(os) == false)
					{
						ArrayList<Double[]> osList = userHalfVecSheffle.get(os);
						//for early-late,compare self-early with early of others
						//for early-late,compare self-late with late of others
						txt += Math.sqrt(jensenShannonDivergence(sList.get(0),osList.get(0))) + ",";
						txt += Math.sqrt(jensenShannonDivergence(sList.get(1),osList.get(1))) + ",";
					}
				}
				pw.println(txt.substring(0,txt.length()-1));	//drop the last comma and print 				

			}
			pw.close();

		} catch (Exception e) {
			e.printStackTrace();
		} finally {
		    if (pw != null)
		    	pw.close();
		}
	}


	private static void readData(String path, Map<String, ArrayList<Double[]>> userHalfVecSheffle) {

		ArrayList<Double[]> list = new ArrayList<Double[]>();
		BufferedReader br = null;
		try{
			br = new BufferedReader(new FileReader(path));
			String line = null;
			String[] clmn;
			boolean isHeader = true;
			while ((line = br.readLine()) != null) {
				if (isHeader)
				{
					isHeader = false;
					continue;
				}
				clmn = line.split(","); //format is:dataset,user,half,comma-separate list of patterns
				list = userHalfVecSheffle.get(clmn[0]+","+clmn[1]);
				Double[] half = new Double[clmn.length-3];
				for (int i=3; i< clmn.length;i++)
					half[i-3] = Double.parseDouble(clmn[i]);
				
				if (list != null){
					list.add(half);
				}else{
					list = new ArrayList<Double[]>();
					list.add(half);
					userHalfVecSheffle.put(clmn[0]+","+clmn[1],list);
				}
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

	private static void GenerateWriteFreqPatternsVectorsAll(String fname, Map<String, ArrayList<String>> map) {
		PrintWriter pw = null;
		try {

			File file = new File(fname);
			if (!file.getParentFile().exists())
				file.getParentFile().mkdirs();
			if (!file.exists()) {
				file.createNewFile();
			}

			pw = new PrintWriter(new FileWriter(file, false));
			String header = "";
			for (String s : freqPatternList)
				header = header + "," + s;

			pw.println("dataset,user,half"+ header);
			
			for (String datasetuser : map.keySet()) {//key is dataset,user
				
				ArrayList<String> list = map.get(datasetuser);
				generateWriteHalfFreqPatternsVectors(pw, datasetuser,list,0);				
			}
			pw.close();
		} catch (IOException e) {
			e.printStackTrace();
		} finally {
		    if (pw != null)
		    	pw.close();
		}
	}

	private static void GenerateWriteFreqPatternsVectors(String fname, Map<String, ArrayList<String>> map) {
		PrintWriter pw = null;
		try {

			File file = new File(fname);
			if (!file.getParentFile().exists())
				file.getParentFile().mkdirs();
			if (!file.exists()) {
				file.createNewFile();
			}

			pw = new PrintWriter(new FileWriter(file, false));
			String header = "";
			for (String s : freqPatternList)
				header = header + "," + s;

			pw.println("dataset,user,half"+ header);
			
			for (String datasetuser : map.keySet()) {//key is dataset,user
				
				ArrayList<String> list = map.get(datasetuser);
				generateWriteHalfFreqPatternsVectors(pw, datasetuser,list.subList(0, split2Half(list.size())),1);
				generateWriteHalfFreqPatternsVectors(pw, datasetuser,list.subList(split2Half(list.size()), list.size()),2);
				
				}
			pw.close();
		} catch (IOException e) {
			e.printStackTrace();
		} finally {
		    if (pw != null)
		    	pw.close();
		}
	}

	private static int split2Half(int size) {
		if (size % 2 == 0)
			return size/2;
		else 
			return (size/2)+1;
	}

	private static void generateWriteHalfFreqPatternsVectors(PrintWriter pw,
			String datasetuser, List<String> list, int half) {
		
		Map<String, Integer> freqMap = new HashMap<String,Integer>();//keeps sum of freqs pattern for all std's exercise sequences
		
		for (String user_patt : list)
		{
			for (String s : freqPatternList) {
				Pattern pattern = Pattern.compile(s); 
				Matcher matcher = pattern.matcher(user_patt);
				int match = 0;
				while (matcher.find())
					match++;
				freqMap.put(s, (freqMap.get(s)==null?match:freqMap.get(s)+match));
			}
		}
		//print student normalized frequency vectors
		double sum = 0;
		for (int val : freqMap.values())
			sum+=val;
		String txt = datasetuser+","+half+",";
		for (String fpatt : freqPatternList) {
			txt = txt + freqMap.get(fpatt)/sum +",";

		}
		pw.println(txt.substring(0,txt.length()-1));	//drop the last comma and print it				
	}

	private static void readAllStudentSequences(String path) {
		userSeqMap = new HashMap<String,ArrayList<String>>();
		BufferedReader br = null;
		ArrayList<String> list;
		try{
			br = new BufferedReader(new FileReader(path));
			String line = null;
			String[] clmn;
			while ((line = br.readLine()) != null) {
				clmn = line.split(","); //format is:s2014-ohpe,e32a8f9a539751f3179722e96bd244d5,viikko2-Viikko2_030.MihinJaMista,0,0,0,0,0,0,0,0,_jjaca_,0.3,5.0
				if (clmn[1].equals(""))
					continue;
				list = userSeqMap.get(clmn[0]+","+clmn[1]);//key is dataset,user
				if (list != null){ 
					list.add(clmn[11]);
				}else{
					list = new ArrayList<String>();
					list.add(clmn[11]);
					userSeqMap.put(clmn[0]+","+clmn[1], list);//key is dataset,user
				}
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

	private static void readMostFrequentPattern(String path) {
		freqPatternList = new ArrayList<String>();
		BufferedReader br = null;
		try{
			br = new BufferedReader(new FileReader(path));
			String line = null;
			String[] clmn;
			while ((line = br.readLine()) != null) {
				clmn = line.split("\t"); //format is:_(II)(tab)_A(tab)#cases: 42483 out of 94101 (45.15%)
//				if (clmn[1].replaceAll("_", "").length() > 1) //if frePattern has length greater than 1
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
	
	  public static double jensenShannonDivergence(Double[] doubles, Double[] doubles2) {
	      assert(doubles.length == doubles2.length);
	      double[] average = new double[doubles.length];
	      for (int i = 0; i < doubles.length; ++i) {
	        average[i] += (doubles[i] + doubles2[i])/2;
	      }
	      return (klDivergence(doubles, average) + klDivergence(doubles2, average))/2;
	    }

	    
	   public static final double log2 = Math.log(2);
	    /**
	     * Returns the KL divergence, K(p1 || p2).
	     *
	     * The log is w.r.t. base 2. <p>
	     *
	     * *Note*: If any value in <tt>p2</tt> is <tt>0.0</tt> then the KL-divergence
	     * is <tt>infinite</tt>. Limin changes it to zero instead of infinite. 
	     * 
	     */
	    public static double klDivergence(Double[] doubles, double[] p2) {


	      double klDiv = 0.0;

	      for (int i = 0; i < doubles.length; ++i) {
	        if (doubles[i] == 0) { continue; }
	        if (p2[i] == 0.0) { continue; } // Limin

	      klDiv += doubles[i] * Math.log( doubles[i] / p2[i] );
	      }

	      return klDiv / log2; // moved this division out of the loop -DM
	    }
}
