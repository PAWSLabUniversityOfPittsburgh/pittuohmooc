package progMooc;
import java.io.BufferedReader;
import java.io.FileReader;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

public class TestOrdering {
	
	public static void main(String[] args) {

		BufferedReader br = null;
		String line = "";
		String[] clmn;
		String user_id = "", prevUser = "";
		List<String> list;
		try {
			boolean isHeader = false;//TODO very important, check input format			
			String dataset = args[0];//TODO This is the full path to the file
			String datasetTag = args[1];
//			String dataset = "/Users/roya/Desktop/ProgMOOC/data/s2012-ohpe_problems/viikko1-001.Nimi.txt";
//			String datasetTag = "s2012-ohpe";
//	 		String dataset = "/Users/roya/Desktop/ProgMOOC/data/s2012-ohpe_problems/viikko1-002.HeiMaailma.txt";
//			String destDir = "/Users/roya/Desktop/ProgMOOC/data/s2012-ohpe_behavLbl/viikko1-002.HeiMaailma.txt";
//			String dataset = "/Users/roya/Desktop/ProgMOOC/data/s2012-ohpe_problems/viikko3-Viikko3_046.LukujenKeskiarvo.txt";
//			String destDir = "/Users/roya/Desktop/ProgMOOC/data/s2012-ohpe_behavLbl/viikko3-Viikko3_046.LukujenKeskiarvo.txt";
//			String datasetTag = "s2012-ohpe";
     		br = new BufferedReader(new FileReader(dataset));
			
     		list = new ArrayList<String>();
     		list.clear();
     		int count = 0;
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
				count++;
				clmn = line.split(";");
				user_id = clmn[1];
				
				if (prevUser.equals(user_id) == false) //Here we have moved to the new user
				{
					if (list.contains(user_id)) 
						System.out.println(count+"  "+"USER DATA IN SEPARATE BLOCKS: "+datasetTag+"  rowID="+clmn[0]+"  ,  userID="+user_id);
					else 
						list.add(user_id);
				}							
				prevUser = user_id;		
			}
			br.close();	
			list.clear();
			list = null;
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
