import java.util.Scanner;
public class BiggerNumber {
    public static void main(String[] args) {
         Scanner input = new Scanner(System.in);
         System.out.println("Type a number:  ");
         int firstNumber = Integer.parseInt(input.nextLine());
         System.out.println("Type another number:  ");
         int secondNumber = Integer.parseInt(input.nextLine());
         if (firstNumber > secondNumber)
             System.out.println("The bigger number was: " + firstNumber);
        else if (firstNumber < secondNumber)
             System.out.println("The bigger number was: " + secondNumber);
         else 
             System.out.println("Numbers were equal: ");
    }
}
