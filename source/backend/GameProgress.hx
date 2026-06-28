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
        ['Unlock Test', false],
        ['Unlock Settings', false],
        ['Buy all items', false],
        ['Get all trophies', false],
        ['Talk to Madera', false]
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

    public static function reset()
    {
        FlxG.sound.play(Paths.sound('confirmMenu'));

        todoTasks = [
            ['Beat Week 1', false],
            ['Beat Week 2', false],
            ['Beat Week 3', false],
            ['Beat Week 4', false],
            ['Beat Week 5', false],
            ['Unlock Pico', false],
            ['Unlock Madness', false],
            ['Unlock R.A.M', false],
            ['Unlock Test', false],
            ['Unlock Settings', false],
            ['Buy all items', false],
            ['Get all trophies', false],
            ['Talk to Madera', false]
        ];

        FlxG.save.data.todoTasks = [
            ['Beat Week 1', false],
            ['Beat Week 2', false],
            ['Beat Week 3', false],
            ['Beat Week 4', false],
            ['Beat Week 5', false],
            ['Unlock Pico', false],
            ['Unlock Madness', false],
            ['Unlock R.A.M', false],
            ['Unlock Test', false],
            ['Unlock Settings', false],
            ['Buy all items', false],
            ['Get all trophies', false],
            ['Talk to Madera', false]
        ];
        
        FlxG.save.flush();
    }
}