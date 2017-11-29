package progMooc;
import java.io.BufferedReader;
import java.io.File;
import java.io.FileReader;
import java.io.FileWriter;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.HashMap;
import java.util.Map;
import java.util.TreeMap;

public class BehavPatternExercise_twelveLBL_prevsnapshot {
	static Map<String, Double> medianMap = new HashMap<String,Double>(); //<exercise,median i.e. from log time>
	static ArrayList<String> validusrcourseMap = new ArrayList<String>(); //

	public static void main(String[] args) {

		String dataset = args[0];//TODO This is the full path to the file
		String destDir = args[1];
		String datasetTag = args[2];
		String path = args[3]; //pathToMedianFile
		String validusrcourse = args[4];
		int thresholdVarIndx = Integer.parseInt(args[5]);
//		String dataset = "/Users/roya/Desktop/ProgMOOC/data/s2014-ohpe_all.txt";
//		String destDir = "/Users/roya/Desktop/ProgMOOC/code/java/source_codes/progMooc/resource/s2014-ohpe_all_behav.txt";
//		String datasetTag = "s2014-ohpe";
//		String path = "/Users/roya/Desktop/ProgMOOC/code/java/source_codes/progMooc/resource/MedianTimeSnapshotPerExercise.txt";
		BufferedReader br = null;
		String line = "";
		String[] clmn;
		String user_id = "", prevUser = "",prev_exe="";
		double psResult = -1.0;
		int psConcept = -1;
		String pattern = "";
		int pConcepts = -1;
		double pResult = -1;
		int builder=0, reducer=0, massager=0, struggler=0;
		long buildsec=0, reducesec=0, massagesec=0, strugglesec=0;
		Map<String,String[]> map = new HashMap<String,String[]>(); //Map<"dataset,user,exe",
		//{build,reduce,massage,struggle,buildsec,reducesec,massagesec,
		//strugglesec,pattern,sumCorrectness, noNonGenericSnapshot}>
		Map<String, Double[]> res = new HashMap<String,Double[]>(); //Map<"dataset,user,exe", {maxres, nattempts}>
				
		BehavPatternExercise_twelveLBL_prevsnapshot.readMedians(path);
		BehavPatternExercise_twelveLBL_prevsnapshot.readvalidusrcourse(validusrcourse);
		int noNonGenericSnapshots = 0;
		double sumCorrectness = 0;
		int noattempts = 0; 
		String prev_rowid = "0";
		try {
			String delimConcepts = ",";//TODO very important, check input format
			String delimConceptsNum = ":";//TODO very important, check input format
			String cvsSplitBy = ";";//TODO very important, check input format
			boolean isHeader = false;//TODO very important, check input format			

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
				if (clmn[16].equals("null") | clmn[16].trim().isEmpty() )
					continue;
				
				user_id = clmn[1];
				String[] conceptList = clmn[16].split(delimConcepts);
				
				int concepts = 0;
				
				
				for (String s : conceptList)
				{	
					try{
					concepts += Integer.parseInt(s.split(delimConceptsNum)[1]);
					}catch(Exception e){
						System.out.println("UNEXPECTED CONCEPT FORMAT: Dataset="+datasetTag+" , rowID="+clmn[0]+" , originalConcepts="+clmn[16]);
					}
				}
				
				double result = 0.0;
				if (clmn[11].equals("null") & clmn[9].equals("false"))
					result = 0.0;
				else
					result = Double.parseDouble(clmn[11]);
				if (clmn[7].equals("false"))//we consider not compilable codes same as cases that amount of tests passed are 0.
					result = 0;
				if (clmn[7].equals("true") & clmn[9].equals("false"))//another case that result should be 0 (testCompile = False while sourceCompile=True)
					result = 0;
				String[] baselineConcepts = clmn[17].split(delimConcepts);
				//check if we moved to the new user or the exercise is changed
				if ( (prevUser.equals(user_id) == false) | (prev_exe.equals(clmn[3]) == false) ){ 
					String[] list = map.get(datasetTag+","+prevUser+","+prev_exe); //key in map: "dataset,user,exe"
					if (list != null) //list is not null when user has had series of generic snapshots in the problem without RUN/TEST/SUBMIT
					{
						//add the behaviours to the previous behaviours of the student in the problem
						//{build,reduce,massage,struggler,buildsec,reducesec,massagesec,
						//strugglesec,pattern,sumCorrectness, noNonGenericSnapshot}>
						list[0] = ""+ (Integer.parseInt(list[0]) + builder);
						list[1] = ""+ (Integer.parseInt(list[1]) + reducer);
						list[2] = ""+ (Integer.parseInt(list[2]) + massager);
						list[3] = ""+ (Integer.parseInt(list[3]) + struggler);
						list[4] = ""+ (Long.parseLong(list[4]) + buildsec);
						list[5] = ""+ (Long.parseLong(list[5]) + reducesec);
						list[6] = ""+ (Long.parseLong(list[6]) + massagesec);
						list[7] = ""+ (Long.parseLong(list[7]) + strugglesec);
						list[8] = list[8]+pattern;
						list[9] = ""+sumCorrectness;
						list[10] = ""+noNonGenericSnapshots;
						list[11] = ""+prev_rowid;

					} else	{				
						list = new String[]{""+builder, ""+reducer, ""+massager, ""+struggler,
							             	""+buildsec, ""+reducesec, ""+massagesec,""+strugglesec,pattern 
							             	, ""+sumCorrectness, ""+noNonGenericSnapshots,prev_rowid};
						 map.put(datasetTag+","+prevUser+","+prev_exe, list);
					}					
															
					builder=0; reducer=0; massager=0; struggler=0; pattern="";
					buildsec=0; reducesec=0; massagesec=0; strugglesec=0;
					noNonGenericSnapshots = 0;
					sumCorrectness = 0;
					noattempts = 0;

					if (baselineConcepts[0].equals("0"))
					{
						pConcepts = 0;
						pResult = 0;
						psConcept = -1;
						psResult = 0;
					}else{
						int baselines = 0;
						if (baselineConcepts.length > 0)
						{
							for (String s : baselineConcepts)
							{			
								try{
									baselines += Integer.parseInt(s.split(delimConceptsNum)[1]);
								}catch(Exception e){
									System.out.println("UNEXPECTED CONCEPT FORMAT: Dataset="+datasetTag+" , rowID="+clmn[0]+" , originalConcepts="+clmn[16]);
								}
							}
						}	
						//if not baseline is empty
						pConcepts = baselines;
						pResult = 0;
						psConcept = -1;
						psResult = 0;
					}
				}		
				//TODO: Check with Arto
				if (clmn[6].equals("null")){
					//System.out.println("timeSincePrev is null,rowid is:"+clmn[0]);
					clmn[6] = "0";
				}
				else if (Long.parseLong(clmn[6]) > 1200000 ){
					//System.out.println("timeSincePrev is greater than 20 minutes,rowid is:"+clmn[0]);	
					clmn[6] = "1200000";// this is in milliseconds that is the unit for the column
				}
				else if (Long.parseLong(clmn[6]) < 0)//this error should never happen
					System.out.println("Error -- timeSincePrev is negative : row-id: "+clmn[0]);
				
				double medExeInLogMillisec = medianMap.get(datasetTag+","+clmn[thresholdVarIndx]); //format is: datasetTag+","+e+","+median (log of millisecs)
				double logTimeOnSnapMillisec = Math.log(Long.parseLong(clmn[6]));
				
//				if (result == pResult & concepts == pConcepts)
//					{pattern += "";}//this should be empty because we cannot dig patterns since the length of this case vary for different students
				if (result != 0)
				{
					if (result > pResult) {  //3rd row
						if (concepts > pConcepts)						
							{pattern += getLabel("a",logTimeOnSnapMillisec,medExeInLogMillisec);}
						else if (concepts < pConcepts)
							{pattern += getLabel("b",logTimeOnSnapMillisec,medExeInLogMillisec);}
						else if (concepts == pConcepts)
						{pattern += getLabel("c",logTimeOnSnapMillisec,medExeInLogMillisec); }							
//						psResult = result;
//						psConcept = concepts;
					} else if (result == pResult)  //4th row
					{
						if (concepts > pConcepts)						
						   {pattern += getLabel("d",logTimeOnSnapMillisec,medExeInLogMillisec); }
						
						else if (concepts < pConcepts)						
					         	{pattern += getLabel("e",logTimeOnSnapMillisec,medExeInLogMillisec);}
						else if (concepts == pConcepts)						
						        {pattern += getLabel("f",logTimeOnSnapMillisec,medExeInLogMillisec); }

					}
					else if (result < pResult) 
					{
						if (concepts > pConcepts)						
						   {pattern += getLabel("g",logTimeOnSnapMillisec,medExeInLogMillisec);}
						else if (concepts < pConcepts)						
					         	{pattern += getLabel("h",logTimeOnSnapMillisec,medExeInLogMillisec); }
						else if (concepts == pConcepts)						
						        {pattern += getLabel("i",logTimeOnSnapMillisec,medExeInLogMillisec);}
					}
				}			
				else if (result == 0)
				{
					if (concepts > pConcepts)						
					   {pattern += getLabel("j",logTimeOnSnapMillisec,medExeInLogMillisec);}
					else if (concepts < pConcepts)						
				         	{pattern += getLabel("k",logTimeOnSnapMillisec,medExeInLogMillisec); }
					else if (concepts == pConcepts)						
					        {pattern += getLabel("l",logTimeOnSnapMillisec,medExeInLogMillisec);}
				}
				pConcepts = concepts;
				pResult = result;	
				
				if (clmn[4].equals("TEST") | clmn[4].equals("RUN") | clmn[4].equals("SUBMIT")){ //if this is the submission
					
					noNonGenericSnapshots++;
					sumCorrectness += result;
					
					Double[] scoresRes = res.get(datasetTag+","+user_id+","+clmn[3]);
					if (scoresRes != null)
					{
						if (scoresRes[0] < 1)
						{
							noattempts ++;
							res.put(datasetTag+","+user_id+","+clmn[3], new Double[]{result,(double)noattempts});
						}
					}else{
						noattempts ++;
						res.put(datasetTag+","+user_id+","+clmn[3], new Double[]{result,(double)noattempts});
					}
				}

									
				prevUser = user_id;	
				prev_exe = clmn[3];
				prev_rowid = clmn[0];
			}
			br.close();	
			//sorting based on time (rowid)
			Map<String,String[]> tmp = new HashMap<String,String[]>();
			ValueComparatorData vc = new ValueComparatorData(tmp);
			TreeMap<String,String[]>  sortedTreeMap = new TreeMap<String,String[]>(vc);
			tmp.putAll(map);
			sortedTreeMap.putAll(tmp);

			//print the information
			for (String u : sortedTreeMap.keySet())
			{
				String[] arr = u.split(",");
				if (arr.length > 1)
				{
					if (validusrcourseMap.contains(arr[1]+","+arr[0]))
					{
						//Map<"dataset,user,exe",
						//{build,reduce,massage,struggle,buildsec,reducesec,massagesec,
						//strugglesec,pattern,sumCorrectness, noNonGenericSnapshot}>
						String[] l = map.get(u);
						pw.println(u+","+l[0]+","+l[1]+","+l[2]+","+l[3]+","+l[4]+","+l[5]+","+
							l[6]+","+l[7]+","+"_"+l[8]+"_,"+ //_ is added to the first and end of the sequence as in genome.
							(Integer.parseInt(l[10])>0?Double.parseDouble(l[9])/Integer.parseInt(l[10]):0)+","+
							(res.get(u)!=null?res.get(u)[1]:0)+","+l[11]);//the array has two elements, first is result, second is the noattempts.note if noattempts = 0, it means user did not have any nonGeneric Snapshot.
					}
				}
				
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
	
	

	private static void readvalidusrcourse(String path) {
		BufferedReader br = null;
		try{
			br = new BufferedReader(new FileReader(path));
			String line = null;
			String[] clmn;
			while ((line = br.readLine()) != null) {
				clmn = line.split("\t"); //format is: 7a67d89b0315ba1a09a41779eed0cec8	k2014-mooc,	k2014-mooc
				String course = clmn[2];
				if (course.equals("hy-s2015-ohpe"))
					course = "s2015-ohpe";
				else if (course.equals("k2015-ohjelmointi"))
					course = "k2015-mooc";
				validusrcourseMap.add(clmn[0]+","+course);
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



	private static String getLabel(String behav, double logTimeOnSnapMillisec,double medExe) {
		if (logTimeOnSnapMillisec>medExe)
		{
			return behav.toUpperCase();
		}else{
			return behav;
		}
//		return behav;
	}



	private static void readMedians(String path) {
		BufferedReader br = null;
		try{
			br = new BufferedReader(new FileReader(path));
			String line = null;
			String[] clmn;
			while ((line = br.readLine()) != null) {
				clmn = line.split(","); //format is: datasetTag+","+e/u+","+median
				medianMap.put(clmn[0]+","+clmn[1],Double.parseDouble(clmn[2]));
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
	
	private static class ValueComparatorData implements Comparator<String> {

	    Map<String,String[]> base;
	    public ValueComparatorData(Map<String,String[]> base) {
	        this.base = base;
	    }

	    // Note: this comparator sorts the values ascendingly
		public int compare(String a, String b) {
			String[] l1 = base.get(a);
			String[] l2 = base.get(b);
			if (Integer.parseInt(l1[l1.length-1]) > Integer.parseInt(l2[l2.length-1])) {
	            return 1;
	        } else {
	            return -1;
	        } // 
	    }
	}

}
