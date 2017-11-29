package progMooc;
import java.io.BufferedReader;
import java.io.File;
import java.io.FileReader;
import java.io.FileWriter;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.HashMap;
import java.util.Map;
public class BehavLbl_PSS4 {
	
	public static void main(String[] args) {

		BufferedReader br = null;
		String line = "";
		String[] clmn;
		String user_id = "", prevUser = "",prev_exe="";
		double psResult = -1.0;
		int psConcept = -1;
		String cur_behav = "";
		int pConcepts = -1;
		double pResult = -1;
		int builder=0, reducer=0, massager=0, struggler=0;
		long buildsec=0, reducesec=0, massagesec=0, strugglesec=0;
		Map<String,String[]> map = new HashMap<String,String[]>(); //Map<"dataset,user,exe",{build,reduce,massage,struggle,buildsec,reducesec,massagesec,strugglesec}>

		try {
			String delimConcepts = ",";//TODO very important, check input format
			String delimConceptsNum = ":";//TODO very important, check input format
			String cvsSplitBy = ";";//TODO very important, check input format
			boolean isHeader = false;//TODO very important, check input format			
			String dataset = args[0];//TODO This is the full path to the file
			String destDir = args[1];
			String datasetTag = args[2];
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
						//value format of the map: {build,reduce,massage,struggle,buildsec,reducesec,massagesec,strugglesec}
						list[0] = ""+ (Integer.parseInt(list[0]) + builder);
						list[1] = ""+ (Integer.parseInt(list[1]) + reducer);
						list[2] = ""+ (Integer.parseInt(list[2]) + massager);
						list[3] = ""+ (Integer.parseInt(list[3]) + struggler);
						list[4] = ""+ (Long.parseLong(list[4]) + buildsec);
						list[5] = ""+ (Long.parseLong(list[5]) + reducesec);
						list[6] = ""+ (Long.parseLong(list[6]) + massagesec);
						list[7] = ""+ (Long.parseLong(list[7]) + strugglesec);
					} else	{				
						list = new String[]{""+builder, ""+reducer, ""+massager, ""+struggler,
							             	""+buildsec, ""+reducesec, ""+massagesec,""+strugglesec };
						 map.put(datasetTag+","+prevUser+","+prev_exe, list);
					}
															
					builder=0; reducer=0; massager=0; struggler=0; cur_behav="";
					buildsec=0; reducesec=0; massagesec=0; strugglesec=0;

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
//				else if (Long.parseLong(clmn[6]) > 1200000 ){
//					//System.out.println("timeSincePrev is greater than 20 minutes,rowid is:"+clmn[0]);	
//					clmn[6] = "1200000";// this is in milliseconds that is the unit for the column
//				}
				else if (Long.parseLong(clmn[6]) < 0)//this error should never happen
					System.out.println("Error -- timeSincePrev is negative : row-id: "+clmn[0]);
				
				if (result == pResult & concepts == pConcepts)
					{cur_behav = "-";}//this should be empty because we cannot dig patterns since the length of this case vary for different students
				else if (result != 0)
				{
					if (result > psResult) {  //3rd row
						if (concepts >= psConcept)						
							{cur_behav = "B"; builder++;  buildsec+=(Long.parseLong(clmn[6])/1000);}
						else
							{cur_behav = "R"; reducer++; reducesec+=(Long.parseLong(clmn[6])/1000);}
						psResult = result;
						psConcept = concepts;
					} else if (result == psResult)  //4th row
					{
						if (concepts > psConcept)						
						   {cur_behav = "B"; builder++;  buildsec+=(Long.parseLong(clmn[6])/1000);}
						
						else if (concepts < psConcept)						
					         	{cur_behav = "R"; reducer++;  reducesec+=(Long.parseLong(clmn[6])/1000);}
						else if (concepts == psConcept)						
						        {cur_behav = "M"; massager++; massagesec+=(Long.parseLong(clmn[6])/1000);}

					}
					else if (result < psResult) 
						{cur_behav = "S"; struggler++;  strugglesec+=(Long.parseLong(clmn[6])/1000);} //2nd row													
				}			
				else if (result == 0)
				        {cur_behav = "S"; struggler++;  strugglesec+=(Long.parseLong(clmn[6])/1000);} //1st row
				pConcepts = concepts;
				pResult = result;	
				
				if (clmn[4].equals("TEST") | clmn[4].equals("RUN") | clmn[4].equals("SUBMIT")){ //if this is the submission
					
					//check if the map has some behaviours that should be added to the existing values
					String[] list = map.get(clmn[2]+","+clmn[1]+","+clmn[3]);// map key is: "dataset,user,exe"

					if (list != null)
					{
						//add the previous behaviours info to the existing ones
						//value of map: {build,reduce,massage,struggle,buildsec,reducesec,massagesec,strugglesec}
						builder = Integer.parseInt(list[0]) + builder;
						reducer = Integer.parseInt(list[1]) + reducer;
						massager = Integer.parseInt(list[2]) + massager;
						struggler = Integer.parseInt(list[3]) + struggler;
						buildsec = Long.parseLong(list[4]) + buildsec;
						reducesec = Long.parseLong(list[5]) + reducesec;
						massagesec = Long.parseLong(list[6]) + massagesec;
						strugglesec = Long.parseLong(list[7]) + strugglesec;
					}
					
					// write the summary of the behaviours
					pw.println(clmn[0]+cvsSplitBy+builder+cvsSplitBy+reducer+cvsSplitBy+massager+cvsSplitBy+struggler+cvsSplitBy+
							   buildsec+cvsSplitBy+reducesec+cvsSplitBy+massagesec+cvsSplitBy+strugglesec);
					
					//reset the map for this user exercise. map key is: "dataset,user,exe"
                    map.put(clmn[2]+","+clmn[1]+","+clmn[3],null);
	 

					//reset the behaviours but note that the submission influences pConcept,pResult,psConcept,psResult  			
					builder=0; reducer=0; massager=0; struggler=0; cur_behav="";
					buildsec=0; reducesec=0; massagesec=0; strugglesec=0;
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
