namespace EduTaskHub.Frontend.UnitTests;

public class CounterTests : BunitContext
{
   [Test]
   public void OnCounterPage_WhenClickCounterButton_ShouldIncrement()
   {
       // Arrange
       var cut = Render<Counter>();

       cut.Find("p").InnerHtml.MarkupMatches("Current count: 0");

       // Act
       cut.Find("button").Click();

       // Assert
       cut.Find("p").InnerHtml.MarkupMatches("Current count: 1");
   }
}
