package progMooc;
import java.io.BufferedReader;
import java.io.File;
import java.io.FileReader;
import java.io.FileWriter;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.HashMap;
import java.util.Map;

public class BehavLbl_PS12 {

	public static void main(String[] args) {

		String dataset = args[0];//TODO This is the full path to the file
		String destDir = args[1];
		String datasetTag = args[2];
//		String path = args[3]; //pathToMedianFile
//		String validusrcourse = args[4];
//		String dataset = "/Users/roya/Desktop/ProgMOOC/data/s2014-ohpe_all.txt";
//		String destDir = "/Users/roya/Desktop/ProgMOOC/code/java/source_codes/progMooc/resource/s2014-ohpe_all_behav.txt";
//		String datasetTag = "s2014-ohpe";
//		String path = "/Users/roya/Desktop/ProgMOOC/code/java/source_codes/progMooc/resource/MedianTimeSnapshotPerExercise.txt";
		BufferedReader br = null;
		String line = "";
		String[] clmn;
		String user_id = "", prevUser = "",prev_exe="";
//		double psResult = -1.0;
//		int psConcept = -1;
		String cur_behav = "";
		int pConcepts = -1;
		double pResult = -1;
		int aFreq=0, bFreq=0, cFreq=0, dFreq=0, eFreq=0, fFreq=0, gFreq=0, hFreq=0, iFreq=0, jFreq=0,kFreq=0,lFreq=0;
		long aSec=0, bSec=0, cSec=0, dSec=0, eSec=0, fSec=0, gSec=0, hSec=0, iSec=0, jSec=0,kSec=0,lSec=0;
		Map<String,String[]> map = new HashMap<String,String[]>(); //Map<"dataset,user,exe",
		//{build,reduce,massage,struggle,buildsec,reducesec,massagesec,
		//strugglesec,pattern,sumCorrectness, noNonGenericSnapshot}>
		//Map<String, Double[]> res = new HashMap<String,Double[]>(); //Map<"dataset,user,exe", {maxres, nattempts}>
				
//		int noattempts = 0; 
//		String prev_rowid = "0";
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
						list[0] = ""+ (Integer.parseInt(list[0]) + aFreq);
						list[1] = ""+ (Integer.parseInt(list[1]) + bFreq);
						list[2] = ""+ (Integer.parseInt(list[2]) + cFreq);
						list[3] = ""+ (Integer.parseInt(list[3]) + dFreq);
						list[4] = ""+ (Integer.parseInt(list[4]) + eFreq);
						list[5] = ""+ (Integer.parseInt(list[5]) + fFreq);
						list[6] = ""+ (Integer.parseInt(list[6]) + gFreq);
						list[7] = ""+ (Integer.parseInt(list[7]) + hFreq);
						list[8] = ""+ (Integer.parseInt(list[8]) + iFreq);
						list[9] = ""+ (Integer.parseInt(list[9]) + jFreq);
						list[10] = ""+ (Integer.parseInt(list[10]) + kFreq);
						list[11] = ""+ (Integer.parseInt(list[11]) + lFreq);
						//time
						list[12] = ""+ (Long.parseLong(list[12]) + aSec);
						list[13] = ""+ (Long.parseLong(list[13]) + bSec);
						list[14] = ""+ (Long.parseLong(list[14]) + cSec);
						list[15] = ""+ (Long.parseLong(list[15]) + dSec);
						list[16] = ""+ (Long.parseLong(list[16]) + eSec);
						list[17] = ""+ (Long.parseLong(list[17]) + fSec);
						list[18] = ""+ (Long.parseLong(list[18]) + gSec);
						list[19] = ""+ (Long.parseLong(list[19]) + hSec);
						list[20] = ""+ (Long.parseLong(list[20]) + iSec);
						list[21] = ""+ (Long.parseLong(list[21]) + jSec);
						list[22] = ""+ (Long.parseLong(list[22]) + kSec);
						list[23] = ""+ (Long.parseLong(list[23]) + lSec);
//						list[24] = ""+prev_rowid;

					} else	{				
						list = new String[]{""+aFreq, ""+bFreq, ""+cFreq, 
											""+dFreq, ""+eFreq, ""+fFreq,
											""+gFreq, ""+hFreq, ""+iFreq,
											""+jFreq, ""+kFreq, ""+lFreq,
											//time
											""+aSec, ""+bSec, ""+cSec, 
											""+dSec, ""+eSec, ""+fSec,
											""+gSec, ""+hSec, ""+iSec,
											""+jSec, ""+kSec, ""+lSec,
							             	//,prev_rowid
											};
						 map.put(datasetTag+","+prevUser+","+prev_exe, list);
					}					
					
					aFreq=0; bFreq=0; cFreq=0; dFreq=0; eFreq=0; fFreq=0; gFreq=0; hFreq=0; iFreq=0; jFreq=0;kFreq=0;lFreq=0;
					aSec=0; bSec=0; cSec=0; dSec=0; eSec=0; fSec=0; gSec=0; hSec=0; iSec=0; jSec=0; kSec=0; lSec=0;
					cur_behav = "";
//					noattempts = 0;

					if (baselineConcepts[0].equals("0"))
					{
						pConcepts = 0;
						pResult = 0;
//						psConcept = -1;
//						psResult = 0;
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
//						psConcept = -1;
//						psResult = 0;
					}
				}		
				//TODO: Check with Arto
				if (clmn[6].equals("null")){
					//System.out.println("timeSincePrev is null,rowid is:"+clmn[0]);
					clmn[6] = "0";
				}
//				else if (Long.parseLong(clmn[6]) > 1200000 ){
//					//System.out.println("timeSincePrev is greater than 20 minutes,rowid is:"+clmn[0]);	
//					clmn[6] = "1200000";// this is in milliseconds that is the unit for the column
//				}
				else if (Long.parseLong(clmn[6]) < 0)//this error should never happen
					System.out.println("Error -- timeSincePrev is negative : row-id: "+clmn[0]);
					
				
//				if (result == pResult & concepts == pConcepts)
//					{pattern += "";}//this should be empty because we cannot dig patterns since the length of this case vary for different students
				if (result != 0)
				{
					if (result > pResult) {  //3rd row
						if (concepts > pConcepts)						
							{cur_behav = "a"; aFreq++; aSec+=(Long.parseLong(clmn[6])/1000);}
						else if (concepts < pConcepts)
							{cur_behav = "b"; bFreq++; bSec+=(Long.parseLong(clmn[6])/1000);}
						else if (concepts == pConcepts)
							{cur_behav = "c"; cFreq++; cSec+=(Long.parseLong(clmn[6])/1000);}							
//						psResult = result;
//						psConcept = concepts;
					} else if (result == pResult)  //4th row
					{
						if (concepts > pConcepts)						
							{cur_behav = "d"; dFreq++; dSec+=(Long.parseLong(clmn[6])/1000);}
						
						else if (concepts < pConcepts)						
							{cur_behav = "e"; eFreq++; eSec+=(Long.parseLong(clmn[6])/1000);}
						else if (concepts == pConcepts)						
							{cur_behav = "f"; fFreq++; fSec+=(Long.parseLong(clmn[6])/1000);}

					}
					else if (result < pResult) 
					{
						if (concepts > pConcepts)						
							{cur_behav = "g"; gFreq++; gSec+=(Long.parseLong(clmn[6])/1000);}
						else if (concepts < pConcepts)						
							{cur_behav = "h"; hFreq++; hSec+=(Long.parseLong(clmn[6])/1000);}
						else if (concepts == pConcepts)						
							{cur_behav = "i"; iFreq++; iSec+=(Long.parseLong(clmn[6])/1000);}
					}
				}			
				else if (result == 0)
				{
					if (concepts > pConcepts)						
						{cur_behav = "j"; jFreq++; jSec+=(Long.parseLong(clmn[6])/1000);}
					else if (concepts < pConcepts)						
						{cur_behav = "k"; kFreq++; kSec+=(Long.parseLong(clmn[6])/1000);}
					else if (concepts == pConcepts)						
						{cur_behav = "l"; lFreq++; lSec+=(Long.parseLong(clmn[6])/1000);}
				}
				pConcepts = concepts;
				pResult = result;	
				
				if (clmn[4].equals("TEST") | clmn[4].equals("RUN") | clmn[4].equals("SUBMIT")){ //if this is the submission
					//check if the map has some behaviours that should be added to the existing values
					String[] list = map.get(clmn[2]+","+clmn[1]+","+clmn[3]);// map key is: "dataset,user,exe"
					if (list != null) //list is not null when user has had series of generic snapshots in the problem without RUN/TEST/SUBMIT
					{
						//add the behaviours to the previous behaviours of the student in the problem
						//{build,reduce,massage,struggler,buildsec,reducesec,massagesec,
						//strugglesec,pattern,sumCorrectness, noNonGenericSnapshot}>
						aFreq = Integer.parseInt(list[0]) + aFreq;
						bFreq = Integer.parseInt(list[1]) + bFreq;
						cFreq = Integer.parseInt(list[2]) + cFreq;
						dFreq = Integer.parseInt(list[3]) + dFreq;
						eFreq = Integer.parseInt(list[4]) + eFreq;
						fFreq = Integer.parseInt(list[5]) + fFreq;
						gFreq = Integer.parseInt(list[6]) + gFreq;
						hFreq = Integer.parseInt(list[7]) + hFreq;
						iFreq = Integer.parseInt(list[8]) + iFreq;
						jFreq = Integer.parseInt(list[9]) + jFreq;
						kFreq = Integer.parseInt(list[10]) + kFreq;
						lFreq = Integer.parseInt(list[11]) + lFreq;
						//time
						aSec = Long.parseLong(list[12]) + aSec;
						bSec = Long.parseLong(list[13]) + bSec;
						cSec = Long.parseLong(list[14]) + cSec;
						dSec = Long.parseLong(list[15]) + dSec;
						eSec = Long.parseLong(list[16]) + eSec;
						fSec = Long.parseLong(list[17]) + fSec;
						gSec = Long.parseLong(list[18]) + gSec;
						hSec = Long.parseLong(list[19]) + hSec;
						iSec = Long.parseLong(list[20]) + iSec;
						jSec = Long.parseLong(list[21]) + jSec;
						kSec = Long.parseLong(list[22]) + kSec;
						lSec = Long.parseLong(list[23]) + lSec;
					}
					
					// write the summary of the behaviours
					pw.println(clmn[0]+cvsSplitBy+aFreq+cvsSplitBy+bFreq+cvsSplitBy+cFreq+
							           cvsSplitBy+dFreq+cvsSplitBy+eFreq+cvsSplitBy+fFreq+
							           cvsSplitBy+gFreq+cvsSplitBy+hFreq+cvsSplitBy+iFreq+
							           cvsSplitBy+jFreq+cvsSplitBy+kFreq+cvsSplitBy+lFreq+
							           //time
							           cvsSplitBy+aSec+cvsSplitBy+bSec+cvsSplitBy+cSec+
							           cvsSplitBy+dSec+cvsSplitBy+eSec+cvsSplitBy+fSec+
							           cvsSplitBy+gSec+cvsSplitBy+hSec+cvsSplitBy+iSec+
							           cvsSplitBy+jSec+cvsSplitBy+kSec+cvsSplitBy+lSec);			    

					//reset the map for this user exercise. map key is: "dataset,user,exe"
                    map.put(clmn[2]+","+clmn[1]+","+clmn[3],null);
	 

					//reset the behaviours but note that the submission influences pConcept,pResult,psConcept,psResult  			
					aFreq=0; bFreq=0; cFreq=0; dFreq=0; eFreq=0; fFreq=0; gFreq=0; hFreq=0; iFreq=0; jFreq=0;kFreq=0;lFreq=0;
					aSec=0; bSec=0; cSec=0; dSec=0; eSec=0; fSec=0; gSec=0; hSec=0; iSec=0; jSec=0; kSec=0; lSec=0;
					cur_behav = "";


//					Double[] scoresRes = res.get(datasetTag+","+user_id+","+clmn[3]);
//					if (scoresRes != null)
//					{
//						if (scoresRes[0] < 1)
//						{
//							noattempts ++;
//							res.put(datasetTag+","+user_id+","+clmn[3], new Double[]{result,(double)noattempts});
//						}
//					}else{
//						noattempts ++;
//						res.put(datasetTag+","+user_id+","+clmn[3], new Double[]{result,(double)noattempts});
//					}
				}

									
				prevUser = user_id;	
				prev_exe = clmn[3];
//				prev_rowid = clmn[0];
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
