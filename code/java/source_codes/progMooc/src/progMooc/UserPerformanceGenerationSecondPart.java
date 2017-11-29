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
public class UserPerformanceGenerationSecondPart {
	
	static Map<String, Integer> usr2ndPartMap = new HashMap<String,Integer>();
	
	static Map<String,Map<String,Double[]>> userProbsPerformance= new HashMap<String,Map<String,Double[]>>();
	static ArrayList<String> usrSolvedProbs = new ArrayList<String>();
	static Map<String,Map<String,Double>> userProbsTime= new HashMap<String,Map<String,Double>>();
	static ArrayList<String> validUserCourse = new ArrayList<String>();
	public static void main(String[] args) {

		BufferedReader br = null;
		String line = "";
		String[] clmn;

		try {
			String cvsSplitBy = ";";//TODO very important, check input format
			boolean isHeader = false;//TODO very important, check input format			
			String dataset = args[0];//TODO This is the full path to the file
			String destDir = args[1];
			String datasetTag = args[2];
			String validUsrCourse = args[3];
			String usr2ndPart = args[4];

//			String dataset = "/Users/roya/Desktop/ProgMOOC/data/s2015-ohpe_all.txt";
//			String destDir = "/Users/roya/Desktop/t.txt";
//			String datasetTag = "s2015-ohpe";
//			String validUsrCourse = "/Users/roya/Desktop/ProgMOOC/code/java/source_codes/progMooc/resource/student_courses_earliestCourse.txt";
//			String usr2ndPart = "/Users/roya/Desktop/ProgMOOC/code/java/source_codes/progMooc/resource/User2ndPart.txt";
			readValidUserCourse(validUsrCourse);
			readUser2ndPart(usr2ndPart);
			
			File file =new File(destDir);
			if (!file.getParentFile().exists())
				file.getParentFile().mkdirs();
			if (!file.exists()){
	    		file.createNewFile();
	    	}
 	    	PrintWriter pw = new PrintWriter(new FileWriter(file, true));			
 	    	File input = new File(dataset);
 	    	if (!input.exists())
 	    		return;
 	    	br = new BufferedReader(new FileReader(dataset));
			
			while ((line = br.readLine()) != null) {
				if (isHeader)
				{
					isHeader = false;
					continue;
				}
			/*
				INPUT FORMAT
				0 rowId (running integer starting from 1)
				1 student
				2 course
				3 exercise
				4 snapshot type (can be generic, run, test or submit; generic is there only for a few initial events)
				5 time (right now in millisecond-formatted unix timestamps if I recall correctly)
				6 time from previous snapshot (in milliseconds)
				7 compiles (true, false)
				8 compilation error codes if the code does not compile (these are separated by commas)
				9 tests compile (false, na (= skipped), true) - NEW
				10 test compilation error codes if the test code does not compile (these are separated by commas) - NEW
				11 portion of unit tests pass (from 0 to 1, -1 if tests have not been run)
				12 test points in this snapshot (a comma separated list of values, shows the points that students get from the tests run in this snapshot)
				13 individual passing test cases (a comma separated lists of strings, each string represents a single test case; format ClassName.testMethodName)
				14 total source code lines
				15 total source code characters
				16 concepts (as a string, each concept with occurrence count, concepts separated by a comma. e.g. println:3,print:5,..)
				17 baseline concepts (the data that the student gets as a starter, in the above format)
				18 changed concepts (concept change from the baseline -- TODO: should this be from previous snapshot?)
				19 number of changed concepts (currently counting every increase and decrease of existing concepts, e.g. adding 2 printlns and removing 1 print adds up to 3 changed concepts)
				20 number of concepts
	        */	
				clmn = line.split(cvsSplitBy);
				if (validUserCourse.contains(clmn[1]+","+datasetTag) == false)
					continue;
				if (Integer.parseInt(clmn[0]) < usr2ndPartMap.get(clmn[1]))
					continue;
				if (clmn[6].equals("null")){
					clmn[6] = "0";
				}
				else if (Long.parseLong(clmn[6]) > 1200000 ){
					//System.out.println("timeSincePrev is greater than 20 minutes,rowid is:"+clmn[0]);	
					clmn[6] = "1200000";// this is in milliseconds that is the unit for the column
				}
				else if (Long.parseLong(clmn[6]) < 0)//this error should never happen
					System.out.println("Error -- timeSincePrev is negative : row-id: "+clmn[0]);
				
				//////////
				if (usrSolvedProbs.contains(clmn[1]+","+clmn[3]) == false)
				{
					Map<String, Double> tmp = userProbsTime.get(clmn[1]);
					if (tmp == null)
					{
						tmp = new HashMap<String,Double>();
						tmp.put(clmn[3],Double.parseDouble(clmn[6])/1000);
						userProbsTime.put(clmn[1], tmp);
					}else
						tmp.put(clmn[3], (tmp.get(clmn[3])==null?0:tmp.get(clmn[3]))+(Double.parseDouble(clmn[6])/1000));
				}
				/////////	
			

				if (clmn[4].equals("TEST") | clmn[4].equals("RUN") | clmn[4].equals("SUBMIT"))
				{	
					double res = Double.parseDouble(clmn[11]);
					if (res < 0)
						res = 0;
					if (res == 1)
					{
						if (usrSolvedProbs.contains(clmn[1]+","+clmn[3])== false)
							usrSolvedProbs.add(clmn[1]+","+clmn[3]);
					}
					Map<String, Double[]> pmap = userProbsPerformance.get(clmn[1]);
					if (pmap == null)
					{
						Double[] l = new Double[2];//{number of attmpts (stop counting when get to correct solution, max result}
						l[0] = 1.0;
						l[1] = res;
						pmap = new HashMap<String,Double[]>();
						pmap.put(clmn[3],l);
						userProbsPerformance.put(clmn[1], pmap);
					}else{
						Double[] emap = pmap.get(clmn[3]);
						if (emap == null){
							emap = new Double[2];//{number of attmpts to get it correct, max result}
							emap[0] = 1.0;
							emap[1] = res;
							pmap.put(clmn[3],emap);
						}else{
							if (emap[1] < 1)
							{
								emap[0]=emap[0]+1;
								if (res > emap[1])
									emap[1] = res; 
							}
						}
					}
				}
			}
			br.close();	
			//find and print the median of concepts on each snapshot

			for (String usr : userProbsPerformance.keySet())
			{
				Map<String, Double[]> map= userProbsPerformance.get(usr);
				int noProbsAttempted = map.size();
				int noProbsSolved = 0;
				double averageAttmptOnSolvedProbs = 0;
				double avgTotalTimeOnSolvedProbs = 0;
				for (String p : map.keySet())
				{
					if (map.get(p)[1] == 1)
					{
						noProbsSolved++;
						averageAttmptOnSolvedProbs+=map.get(p)[0];
						avgTotalTimeOnSolvedProbs += userProbsTime.get(usr).get(p);
					}
				}
				avgTotalTimeOnSolvedProbs = avgTotalTimeOnSolvedProbs/noProbsSolved;
				averageAttmptOnSolvedProbs = averageAttmptOnSolvedProbs/noProbsSolved;
				double percentageSolvedFromAttempted = (double)noProbsSolved/noProbsAttempted;
				pw.println(datasetTag+","+usr+","+noProbsAttempted+","+noProbsSolved+","+
						   percentageSolvedFromAttempted+","+averageAttmptOnSolvedProbs+","+avgTotalTimeOnSolvedProbs);
			}
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
	private static void readUser2ndPart(String path) {

		BufferedReader br = null;
		try{
			br = new BufferedReader(new FileReader(path));
			String line = null;
			String[] clmn;
			while ((line = br.readLine()) != null) {
				clmn = line.split(","); //format is: s2014-ohpe,a6893b283c8ee124bfad88f0c8cb6dea,viikko1-Viikko1_003.Kuusi,5592
				usr2ndPartMap.put(clmn[1],Integer.parseInt(clmn[2]));
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
	private static void readValidUserCourse(String path) {
		BufferedReader br = null;
		try{
			br = new BufferedReader(new FileReader(path));
			String line = null;
			String[] clmn;
			while ((line = br.readLine()) != null) {
				clmn = line.split("\t"); //format is: datasetTag+","+e+","+median
				String course = clmn[2];
				if (course.equals("hy-s2015-ohpe"))
					course = "s2015-ohpe";
				else if (course.equals("k2015-ohjelmointi"))
					course = "k2015-mooc";
				validUserCourse.add(clmn[0]+","+course);
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
