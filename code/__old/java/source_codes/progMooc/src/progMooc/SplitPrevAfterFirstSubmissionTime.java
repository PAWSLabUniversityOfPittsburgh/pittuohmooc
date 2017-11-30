package progMooc;
import java.io.BufferedReader;
import java.io.File;
import java.io.FileReader;
import java.io.FileWriter;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.ArrayList;

public class SplitPrevAfterFirstSubmissionTime {
	static ArrayList<String> hadFirstSubmissionInExe= new ArrayList<String>();//users who are here, reach their first submission for the problem.

	public static void main(String[] args) {

		BufferedReader br = null;
		String line = "";
		String[] clmn;
		String user_id = "", prevUser = "",prev_exe="";
		double psResult = -1.0;
		int psConcept = -1;
		int pConcepts = -1;
		double pResult = -1;
		//Map<"dataset,user,exe",Map<part=1 for before/on first submission or part =2 for any snapshot after first submission,
		try {
			String delimConcepts = ",";//TODO very important, check input format
			String delimConceptsNum = ":";//TODO very important, check input format
			String cvsSplitBy = ";";//TODO very important, check input format
			boolean isHeader = false;//TODO very important, check input format			
			String dataset = args[0];//TODO This is the full path to the file
			String destDir = args[1];
			String datasetTag = args[2];
//			String dataset = "/Users/roya/Desktop/ProgMOOC/data/s2014-ohpe_all.txt";
//			String destDir = "/Users/roya/Desktop/ProgMOOC/code/java/source_codes/progMooc/resource/t.txt";
//			String datasetTag = "s2014-ohpe";
			File file =new File(destDir);
			if (!file.getParentFile().exists())
				file.getParentFile().mkdirs();
			if (!file.exists()){
	    		file.createNewFile();
	    	}
 	    	File input = new File(dataset);
 	    	if (!input.exists())
 	    		return;
 	    	br = new BufferedReader(new FileReader(dataset));
 	    	PrintWriter pw = new PrintWriter(new FileWriter(file, true));	

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
				user_id = clmn[1];
				String[] conceptList = clmn[16].split(delimConcepts);
				int concepts = 0;
				for (String s : conceptList)
				{	
					try{
					concepts += Integer.parseInt(s.split(delimConceptsNum)[1]);
					}catch(Exception e){
						//set the concepts as baselines
						int base = 0;
						String[] bconcepts = clmn[17].split(delimConcepts);
						if (bconcepts.length > 0)
						{
							for (String bcon : bconcepts)
							{			
								try{
									base += Integer.parseInt(bcon.split(delimConceptsNum)[1]);
								}catch(Exception ex){
									System.out.println("UNEXPECTED CONCEPT FORMAT: Dataset="+datasetTag+" , rowID="+clmn[0]+" , originalConcepts="+clmn[16]);
								}							
							}
							concepts = base;
						}
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
									//System.out.println("UNEXPECTED CONCEPT FORMAT: Dataset="+datasetTag+" , rowID="+clmn[0]+" , originalConcepts="+clmn[16]);
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
				
				if (result == pResult & concepts == pConcepts)
					{}//this should be empty because we cannot dig patterns since the length of this case vary for different students
				else if (result != 0)
				{
					if (result > pResult) {  //3rd row
						if (concepts > pConcepts)						
							{pw.println(clmn[3]+","+"a,"+(hadFirstSubmissionInExe.contains(datasetTag+","+user_id+","+clmn[3])?2:2)+","+Long.parseLong(clmn[6])); }
						else if (concepts < pConcepts )
							{pw.println(clmn[3]+","+"b,"+(hadFirstSubmissionInExe.contains(datasetTag+","+user_id+","+clmn[3])?2:2)+","+Long.parseLong(clmn[6])); }
						else if (concepts == pConcepts)
						{pw.println(clmn[3]+","+"c,"+(hadFirstSubmissionInExe.contains(datasetTag+","+user_id+","+clmn[3])?2:2)+","+Long.parseLong(clmn[6])); }							
						psResult = result;
						psConcept = concepts;
					} else if (result == pResult)  //4th row
					{
						if (concepts > pConcepts)						
						   {pw.println(clmn[3]+","+"d,"+(hadFirstSubmissionInExe.contains(datasetTag+","+user_id+","+clmn[3])?2:2)+","+Long.parseLong(clmn[6])); }
						
						else if (concepts < pConcepts)						
						   {pw.println(clmn[3]+","+"e,"+(hadFirstSubmissionInExe.contains(datasetTag+","+user_id+","+clmn[3])?2:2)+","+Long.parseLong(clmn[6])); }
						else if (concepts == pConcepts)						
						   {pw.println(clmn[3]+","+"f,"+(hadFirstSubmissionInExe.contains(datasetTag+","+user_id+","+clmn[3])?2:2)+","+Long.parseLong(clmn[6])); }

					}
					else if (result < pResult) 
					{
							if (concepts > pConcepts)						
							   {pw.println(clmn[3]+","+"g,"+(hadFirstSubmissionInExe.contains(datasetTag+","+user_id+","+clmn[3])?2:2)+","+Long.parseLong(clmn[6])); }
							
							else if (concepts < pConcepts)						
							   {pw.println(clmn[3]+","+"h,"+(hadFirstSubmissionInExe.contains(datasetTag+","+user_id+","+clmn[3])?2:2)+","+Long.parseLong(clmn[6])); }
							else if (concepts == pConcepts)						
							   {pw.println(clmn[3]+","+"i,"+(hadFirstSubmissionInExe.contains(datasetTag+","+user_id+","+clmn[3])?2:2)+","+Long.parseLong(clmn[6])); }

					}
										
				}			
				else if (result == 0)
				{
					if (concepts > pConcepts)						
				       {pw.println(clmn[3]+","+"j,"+(hadFirstSubmissionInExe.contains(datasetTag+","+user_id+","+clmn[3])?2:2)+","+Long.parseLong(clmn[6])); }
					else if (concepts < pConcepts)						
				       {pw.println(clmn[3]+","+"k,"+(hadFirstSubmissionInExe.contains(datasetTag+","+user_id+","+clmn[3])?2:2)+","+Long.parseLong(clmn[6])); }
					else if (concepts == pConcepts)						
				       {pw.println(clmn[3]+","+"l,"+(hadFirstSubmissionInExe.contains(datasetTag+","+user_id+","+clmn[3])?2:2)+","+Long.parseLong(clmn[6])); }

				}

				pConcepts = concepts;
				pResult = result;	
				
				if (clmn[4].equals("TEST") | clmn[4].equals("RUN") | clmn[4].equals("SUBMIT")){ //if this is the submission
					
					if (hadFirstSubmissionInExe.contains(datasetTag+","+user_id+","+clmn[3]) == false)
						hadFirstSubmissionInExe.add(datasetTag+","+user_id+","+clmn[3]);
					//reset the behaviours but note that the submission influences pConcept,pResult,psConcept,psResult  			
				}
				prevUser = user_id;	
				prev_exe = clmn[3];
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

}
