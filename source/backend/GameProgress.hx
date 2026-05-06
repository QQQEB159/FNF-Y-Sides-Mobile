package backend;

class GameProgress
{
    public static var todoTasks:Array<Dynamic> = [
        ['Beat Week 1', false],
        ['Beat Week 2', false],
        ['Beat Week 3', false],
        ['Beat Week 4', false],
        ['Beat Week 5', false],
        ['Unlock Pico', false],
        ['Unlock Madness', false],
        ['Unlock R.A.M', false],
        ['Unlock Options SONG'],
        ['Buy all items', false],
        ['Get all trophies', false],
        ['Talk to Madera', false],
        ['Get ItsTapiiii out of the dev team plz']
    ];

    public static function init()
    {
        if(FlxG.save.data.todoTasks == null) FlxG.save.data.todoTasks = todoTasks;
        todoTasks = FlxG.save.data.todoTasks;
        
        FlxG.save.flush();
    }

    public static function completeTask(taskIndex:Int)
    {
        // yeah kill me idk lmao
        todoTasks[taskIndex].pop();
        todoTasks[taskIndex].push(true);

        FlxG.save.data.todoTasks = todoTasks;
        FlxG.save.flush();
    }
}