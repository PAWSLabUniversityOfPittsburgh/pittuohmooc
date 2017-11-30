package progMooc;
import java.io.BufferedReader;
import java.io.File;
import java.io.FileReader;
import java.io.FileWriter;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashMap;
import java.util.Map;
public class GenerateMedianTimeSnapshotPerExercise {
	
	public static void main(String[] args) {

		BufferedReader br = null;
		String line = "";
		String[] clmn;
		String thresholdVar;

		Map<String,ArrayList<Double>> map = new HashMap<String,ArrayList<Double>>(); //Map<exercise/user, arraylist of log timeSincePrevSnapshot>

		try {
			String cvsSplitBy = ";";//TODO very important, check input format
			boolean isHeader = false;//TODO very important, check input format			
			String dataset = args[0];//TODO This is the full path to the file
			String destDir = args[1];
			String datasetTag = args[2];
			int thresholdIndx = Integer.parseInt(args[3]);
//			String dataset = "/Users/roya/Dropbox/progMooc/data/s2014-ohpe_all.txt";
//			String destDir = "/Users/roya/Dropbox/progMooc/resource/s2014-ohpe_all_behav.txt";
//			String datasetTag = "s2014-ohpe";
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
				
				thresholdVar = clmn[thresholdIndx];//clmn[1] for user, clmn[3] for problem
				if (clmn[6].equals("null")){
					clmn[6] = "0";
				}
				else if (Long.parseLong(clmn[6]) > 1200000 ){
					//System.out.println("timeSincePrev is greater than 20 minutes,rowid is:"+clmn[0]);	
					clmn[6] = "1200000";// this is in milliseconds that is the unit for the column
				}
				else if (Long.parseLong(clmn[6]) < 0)//this error should never happen
					System.out.println("Error -- timeSincePrev is negative : row-id: "+clmn[0]);
				
				ArrayList<Double> list = map.get(thresholdVar);
				if (list != null)
				{
					list.add(Math.log(Double.parseDouble(clmn[6])));
				}else
				{
					list = new ArrayList<Double>();
					list.add(Math.log(Double.parseDouble(clmn[6])));
					map.put(thresholdVar, list);
				}
			}
			br.close();	
			//find and print the median of log(time) on each snapshot
			for (String var : map.keySet())
			{
				ArrayList<Double> l = map.get(var);
				Double[] arr =  l.toArray(new Double[l.size()]);
				Arrays.sort(arr);
			    //System.out.print("Sorted Scores:, ");
			    //for (double x : arr) {
			    //  System.out.print(x + ",");
			    // }
			    // System.out.println("");
			      
			    // Calculate median (middle number)
			    double median = 0;
			    double pos1 = Math.floor((arr.length - 1.0) / 2.0);
			    double pos2 = Math.ceil((arr.length - 1.0) / 2.0);
			    if (pos1 == pos2 ) {
			    	median = arr[(int)pos1];
			    } else {
			    	 median = (arr[(int)pos1] + arr[(int)pos2]) / 2.0 ;
			    }			 
			    //System.out.println("Median: " + median);
			    pw.println(datasetTag+","+var+","+median);
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
}
