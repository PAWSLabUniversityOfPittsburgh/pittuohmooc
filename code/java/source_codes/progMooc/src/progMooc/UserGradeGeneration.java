package progMooc;
import java.io.BufferedReader;
import java.io.File;
import java.io.FileReader;
import java.io.FileWriter;
import java.io.IOException;
import java.io.PrintWriter;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.HashMap;
import java.util.Map;
public class UserGradeGeneration {
	
	static Map<String,Double[]> userGrade= new HashMap<String,Double[]>();
	static Map<String,String> validUserCourse = new HashMap<String,String>();
	public static void main(String[] args) {

		BufferedReader br = null;
		String line = "";
		String[] clmn;

		try {
			String cvsSplitBy = " ";//TODO very important, check input format
			boolean isHeader = true;//TODO very important, check input format			
			String dataset = "/Users/roya/Desktop/ProgMOOC/data/background-data.txt";//TODO This is the full path to the file
			String destDir = "/Users/roya/Desktop/ProgMOOC/code/java/source_codes/progMooc/resource/user-first-last-grade.txt";
			String validUsrCourse = "/Users/roya/Desktop/ProgMOOC/code/java/source_codes/progMooc/resource/student_courses_earliestCourse.txt";
	
			readValidUserCourse(validUsrCourse);

			
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
				a6eeb7a2319da8708381da0207269465 1994 female 2015-10-20,0,2015-11-27,0,2016-03-08,3
	        */	
				clmn = line.split(cvsSplitBy);
				String user = clmn[0];
				String course = validUserCourse.get(user);
				int year = 0;
				if (course == null)
					continue;
				if (course.contains("2015"))
					year = 2015;
				if (course.contains("2014"))
					year = 2014;
				String[] tmp = clmn[3].split(",");
			    SimpleDateFormat d1 = new SimpleDateFormat ("yyyy-MM-dd"); 
			    SimpleDateFormat d2 = new SimpleDateFormat ("yyyy"); 
			    double firstgrade = -2;
			    double lastgrade = -2;
				for (int i = 0; i <= tmp.length-2; i+=2){
					 if (d1.parse(tmp[i]).compareTo(d2.parse(""+year))<0){
						 System.out.println("~~~~  "+line);
					 }else
					 {
						if (firstgrade == -2)
							firstgrade = Double.parseDouble(tmp[i+1]);
						else if (i==tmp.length-2)
							lastgrade = Double.parseDouble(tmp[i+1]);
					 }
				}
				userGrade.put(user, new Double[]{firstgrade,lastgrade});
		}
			
			br.close();	
			//find and print the median of concepts on each snapshot
			for (String usr : userGrade.keySet())
			{
				Double[] arr= userGrade.get(usr);
				pw.println(usr+","+arr[0]+","+arr[1]);
			}
			pw.close();			
		} catch (IOException e) {
			e.printStackTrace();
		} catch (NumberFormatException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		} catch (ParseException e) {
			// TODO Auto-generated catch block
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
				validUserCourse.put(clmn[0],course);
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
