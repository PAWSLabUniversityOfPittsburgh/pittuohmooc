package progMooc;
import java.io.BufferedReader;
import java.io.File;
import java.io.FileReader;
import java.io.FileWriter;
import java.io.IOException;
import java.io.PrintWriter;
public class BehavLbl_format_old {
	
	public static void main(String[] args) {

		BufferedReader br = null;
		String line = "";
		String[] clmn;
		String user_id = "", prevUser = "";
		double psResult = -1.0;
		int psConcept = -1;
		String cur_behav = "";
		int pConcepts = -1;
		double pResult = -1;
		int builder=0, reducer=0, massager=0, struggler=0;
		try {
			String delimConcepts = ",";//TODO very important, check input format
			String delimConceptsNum = ":";//TODO very important, check input format
			String cvsSplitBy = ";";//TODO very important, check input format
			boolean isHeader = false;//TODO very important, check input format			
			String dataset = args[0];//TODO This is the full path to the file
			String destDir = args[1];
			String datasetTag = args[2];
//			String dataset = "/Users/roya/Desktop/ProgMOOC/data/s2012-ohpe_problems/viikko1-001.Nimi.txt";
//			String destDir = "/Users/roya/Desktop/ProgMOOC/data/s2012-ohpe_behavLbl/viikko1-001.Nimi.txt";
//			String dataset = "/Users/roya/Desktop/ProgMOOC/data/s2012-ohpe_problems/viikko1-002.HeiMaailma.txt";
//			String destDir = "/Users/roya/Desktop/ProgMOOC/data/s2012-ohpe_behavLbl/viikko1-002.HeiMaailma.txt";
//			String dataset = "/Users/roya/Desktop/ProgMOOC/data/s2012-ohpe_problems/viikko3-Viikko3_046.LukujenKeskiarvo.txt";
//			String destDir = "/Users/roya/Desktop/ProgMOOC/data/s2012-ohpe_behavLbl/viikko3-Viikko3_046.LukujenKeskiarvo.txt";
//			String datasetTag = "s2012-ohpe";

			File file =new File(destDir);
			if (!file.getParentFile().exists())
				file.getParentFile().mkdirs();
			if (!file.exists()){
	    		file.createNewFile();
	    	}
 	    	PrintWriter pw = new PrintWriter(new FileWriter(file, false));			
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
				0 row;
				1 student;
				2 course;
				3 exercise;
				4 filename;
				5 snapshot_type;
				6 time;
				7 deadline;
				8 minutesToDeadline;
				9 sourceCompiles;
				10 testsCompile;
				11 amountOfTestsPass;
				12 individualPassedTests;
				13 linesOfCode;
				14 characters;
				15 originalConcepts;
				16 concepts;
				17 baselineConcepts;
				18 secondsSinceStart;
				19 secondsSincePreviousSnapshot;
				20 changedConcepts;
				21 conceptsChangedCount;
	        */		
				clmn = line.split(cvsSplitBy);
				user_id = clmn[1];
				String[] conceptList = clmn[15].split(delimConcepts);
				int concepts = 0;
				for (String s : conceptList)
				{	
					try{
					concepts += Integer.parseInt(s.split(delimConceptsNum)[1]);
					}catch(Exception e){System.out.println("UNEXPECTED CONCEPT FORMAT: Dataset="+datasetTag+" , rowID="+clmn[0]+" , originalConcepts="+clmn[15]);};
				}
				double result = 0.0;
				if (clmn[11].equals("null") & clmn[10].equals("false"))
					result = 0.0;
				else
					result = Double.parseDouble(clmn[11]);
				if (clmn[9].equals("false"))//we consider not compilable codes same as cases that amount of tests passed are 0.
					result = 0;
				if (clmn[9].equals("true") & clmn[10].equals("false"))//another case that result should be 0 (testCompile = False while sourceCompile=True)
					result = 0;
				String[] baselineConcepts = clmn[17].split(delimConcepts);
				if (prevUser.equals(user_id) == false){ //if we moved to new user
					builder=0; reducer=0; massager=0; struggler=0; cur_behav="";
					if (baselineConcepts[0].equals("0"))
					{
						pConcepts = 0;
						pResult = 0;
						psConcept = -1;
						psResult = 0;
					}else{
						int baselines = 0;
						if (baselineConcepts.length > 1)
						{
							for (String s : baselineConcepts)
							{			
								try{
									baselines += Integer.parseInt(s.split(delimConceptsNum)[1]);
								}catch(Exception e){System.out.println("UNEXPECTED CONCEPT FORMAT: Dataset="+datasetTag+" , rowID="+clmn[0]+" , originalConcepts="+clmn[17]);};
							}
						}	
						//if not baseline is empty
						pConcepts = baselines;
						pResult = 0;
						psConcept = -1;
						psResult = 0;
					}
				}
						
				
				if (result == pResult & concepts == pConcepts)
					{cur_behav = "-";}//this should be empty because we cannot dig patterns since the length of this case vary for different students
				else if (result != 0)
				{
					if (result > psResult) {  //3rd row
						if (concepts >= psConcept)						
							{cur_behav = "B"; builder++;}
						else
							{cur_behav = "R"; reducer++;}
						psResult = result;
						psConcept = concepts;
					} else if (result == psResult)  //4th row
					{
						if (concepts > psConcept)						
						   {cur_behav = "B"; builder++;}
						
						else if (concepts < psConcept)						
					         	{cur_behav = "R"; reducer++;}
						else if (concepts == psConcept)						
						        {cur_behav = "M"; massager++;}

					}
					else if (result < psResult) 
						{cur_behav = "S"; struggler++;} //2nd row													
				}			
				else if (result == 0)
				        {cur_behav = "S"; struggler++;} //1st row
				pConcepts = concepts;
				pResult = result;	
				
				if (clmn[5].equals("code_submission")){ //if this is the submission
					// write the summary of the behaviours
					pw.println(clmn[0]+cvsSplitBy+builder+cvsSplitBy+reducer+cvsSplitBy+massager+cvsSplitBy+struggler);

					//reset the behaviours but note that the submission influences pConcept,pResult,psConcept,psResult  			
					builder=0; reducer=0; massager=0; struggler=0; cur_behav="";
				}
				prevUser = user_id;		
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
