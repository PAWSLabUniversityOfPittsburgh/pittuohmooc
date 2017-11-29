package progMooc;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileReader;
import java.io.FileWriter;
import java.io.IOException;
import java.io.PrintWriter;

public class SummerizeBehavCorrectness {
	public static void main(String[] args) {

	    String probFile = args[0];//TODO This is the full path to the file
		String outputFile = args[1];

//      String probFile = "/Users/roya/Desktop/ProgMOOC/data/k2014-mooc_problems/viikko1-Viikko1_002.HeiMaailma.txt";
//		String outputFile = "/Users/roya/Desktop/output/output.txt";
		boolean isHeader = false;
		String cvsSplitBy = ";";//TODO very important, check input format

		BufferedReader br = null;
		String line = "";
		String[] clmn;
		String user_id = "", prevUser = "nulluser",prev_exercise="nullexercise";
		
		int countError = 0;
		//
		int builder=0, reducer=0, massager=0, struggler=0;
		long buildsec=0, reducesec=0, massagesec=0, strugglesec=0;
		int noNonGenericSnapshots = 0;
		double sumCorrectness = 0;
		
		boolean hasHeader = true;
		try {
			File file =new File(outputFile);
			if (!file.getParentFile().exists())
				file.getParentFile().mkdirs();
			if (!file.exists()){
	    		file.createNewFile();
	    		hasHeader = false;
	    	}
 	    	PrintWriter pw = new PrintWriter(new FileWriter(file, true));			
 	    	 	    	
 	    	File input = new File(probFile);
 	    	if (!input.exists())
 	    		return;
 	    	br = new BufferedReader(new FileReader(probFile));

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
			21 countBuilder - count of Builder behavior since previous submission (null submission or a normal submission)
			22 countReducer - count of Reducer behavior since previous submission (null submission or a normal submission)
			23 countMassager - count of Massager behavior since previous submission (null submission or a normal submission)
			24 countStruggler - count of Struggler behavior since previous submission (null submission or a normal submission)
			25 buildsec - seconds of Building since previous submission (null submission or a normal submission)
			26 reducesec - seconds of Reducing since previous submission (null submission or a normal submission)
			27 massagesec - seconds of Massaging since previous submission (null submission or a normal submission)
			28 strugglesec - seconds of Struggling since previous submission (null submission or a normal submission)

        */	
			if (hasHeader == false)
				pw.println("dataset"+","+"exercise"+","+"user"+","+"builder"+","+"reducer"+","+"massager"+
			               ","+"struggler"+","+"total.behaviour.count"+","+"percentage.correctness"+
						   ","+"buildsec"+","+"reducesec"+","+"massagesec"+","+"strugglesec");

			while ((line = br.readLine()) != null) {
				if (isHeader)
				{
					isHeader = false;
					continue;
				}
				clmn = line.split(cvsSplitBy);
				user_id = clmn[1];
				
				
				if (prevUser.equals(user_id) == false){ //check if we moved to the new user
					if (prevUser.equals("nulluser") == false){
						//write the summary of the behaviours and correctness for the previous user
						pw.println(clmn[2]+","+clmn[3]+","+prevUser+","+builder+","+reducer+","
						+massager+","+struggler+","+(builder+reducer+massager+struggler)+","
						+sumCorrectness/noNonGenericSnapshots+","+buildsec+","+reducesec+","+massagesec+","+strugglesec);	
						if (buildsec < 0 | reducesec < 0 | strugglesec<0 | massagesec<0)
							System.out.println("Error -- negative sum of behaviour seconds: "+clmn[2]+"  "+clmn[3]+" "+prevUser);
					}
					//reset the variables
					builder=0; reducer=0; massager=0; struggler=0;
					buildsec=0; reducesec=0; massagesec=0; strugglesec=0;
					noNonGenericSnapshots = 0;
					sumCorrectness = 0.0;
				}
				if (prevUser.equals(user_id) == true & prev_exercise.equals(clmn[3]) == false)//check if user is same but exercise is changed
				{
					if (prevUser.equals("nulluser") == false){
						//write the summary of the behaviours and correctness for the previous exercise of this user
						pw.println(clmn[2]+","+prev_exercise+","+user_id+","+builder+","+reducer+","
						+massager+","+struggler+","+(builder+reducer+massager+struggler)+","
						+sumCorrectness/noNonGenericSnapshots+","+buildsec+","+reducesec+","+massagesec+","+strugglesec);		
					}
					//reset the variables
					builder=0; reducer=0; massager=0; struggler=0;
					buildsec=0; reducesec=0; massagesec=0; strugglesec=0;
					noNonGenericSnapshots = 0;
					sumCorrectness = 0.0;
				}
				
				 //if this is the submission
				noNonGenericSnapshots++;
								
			    //1. recording the behaviour summary
			    builder += Integer.parseInt(clmn[21]);
			    reducer += Integer.parseInt(clmn[22]);
			    massager += Integer.parseInt(clmn[23]);				    
			    struggler += Integer.parseInt(clmn[24]);
			   
			    buildsec += Long.parseLong(clmn[25]);
			    reducesec += Long.parseLong(clmn[26]);
			    massagesec += Long.parseLong(clmn[27]);
			    strugglesec += Long.parseLong(clmn[28]);
			    
			    if (Long.parseLong(clmn[25])<0 | Long.parseLong(clmn[26])<0 | Long.parseLong(clmn[27])<0|Long.parseLong(clmn[28])<0)
			    {
			    	countError++;
			    	//System.out.println(clmn[0]+" "+clmn[2]+"  "+Long.parseLong(clmn[25]) +" "+ Long.parseLong(clmn[26])+" "+ Long.parseLong(clmn[27])+" "+Long.parseLong(clmn[28]) );
			    }
			    	
			    //2. recording the correctness of the attempts
				double result = 0.0;
				if (clmn[11].equals("null") & clmn[9].equals("false"))
					result = 0.0;
				else if (Double.parseDouble(clmn[11]) == -1)
					result = 0.0;
				else
					result = Double.parseDouble(clmn[11]);
				sumCorrectness += result;
			    
				prevUser = user_id;
				prev_exercise = clmn[3];
			}
			br.close();	
			pw.close();		
			System.out.println("Total Negative Time Cases :"+countError);
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
