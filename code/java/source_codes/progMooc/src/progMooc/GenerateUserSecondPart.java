package progMooc;
import java.io.BufferedReader;
import java.io.File;
import java.io.FileReader;
import java.io.FileWriter;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class GenerateUserSecondPart {
	
	static Map<String,List<String>> userExeMap = new HashMap<String,List<String>>();
	static Map<String,List<Integer>> userRowIDMap = new HashMap<String,List<Integer>>();

	static ArrayList<String> validUserCourse = new ArrayList<String>();

	public static void main(String[] args) {

		String dataset = args[0];//TODO This is the full path to the file
		String destDir = args[1];
		String datasetTag = args[2];
		String validusrcourse = args[3];
//		String dataset = "/Users/roya/Desktop/ProgMOOC/data/s2014-ohpe_all.txt";
//		String destDir = "/Users/roya/Desktop/t.txt";
//		String datasetTag = "s2014-ohpe";
//		String validusrcourse = "/Users/roya/Desktop/ProgMOOC/code/java/source_codes/progMooc/resource/student_courses_earliestCourse.txt";

		readValidUserCourse(validusrcourse);
		GenerateUserSecondPart.readData(dataset,datasetTag);	
		writeUserExeData(destDir,datasetTag);
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
	
	private static void writeUserExeData(String fname,String datasetTag) {
		PrintWriter pw = null;
		try {

			File file = new File(fname);
			if (!file.getParentFile().exists())
				file.getParentFile().mkdirs();
			if (!file.exists()) {
				file.createNewFile();
			}

			pw = new PrintWriter(new FileWriter(file, true));
			for (String usr : userExeMap.keySet()){
				List<String> list = userExeMap.get(usr); 
				pw.println(datasetTag+","+usr+","+userRowIDMap.get(usr).get(list.size()/2));
			}
			pw.close();
		} catch (IOException e) {
			e.printStackTrace();
		} finally {
		    if (pw != null)
		    	pw.close();
		}
	}

	private static void readData(String path,String datasetTag) {
		userExeMap = new HashMap<String,List<String>>();
		userRowIDMap = new HashMap<String,List<Integer>>();

		BufferedReader br = null;
		try{
			br = new BufferedReader(new FileReader(path));
			String line = null;
			String[] clmn;
			while ((line = br.readLine()) != null) {
				clmn = line.split(";"); 
				if (validUserCourse.contains(clmn[1]+","+datasetTag) == false)
					continue;
				List<String> list = userExeMap.get(clmn[1]);
				if (list == null)
				{
					list = new ArrayList<String>();
					List<Integer> ids = new ArrayList<Integer>();
					list.add(clmn[3]);
					ids.add(Integer.parseInt(clmn[0]));
					userExeMap.put(clmn[1], list);
					userRowIDMap.put(clmn[1], ids);
				}else
				{
					if (list.get(list.size()-1).equals(clmn[3])==false){
						list.add(clmn[3]);
						List<Integer> ids = userRowIDMap.get(clmn[1]);
						ids.add(Integer.parseInt(clmn[0]));
					}
				}
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
