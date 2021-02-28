<# Authot: Bryan Evans
   Date: 2/27/2021

   Use instructions: Requires execution policy to be set to "Unrestricted". In an elevated 
   Powershell window, run: "Set-ExecutionPolicy Unrestricted".  You can set it back to "Restricted" 
   afterwards.
   
   Run this script in the same directory as probabilities.csv which should contain all of the
   probability information for the draft lottery.  CSV file should be structured with the following 
   three columns of data (values are examples):
            _________________________________________ 
           |   TEAM   |  PROBABILITY  |  CUMULATIVE  |
           |  team A  |      14%      |      0.0     |
           |  team B  |       9%      |     14.0     |
           |  team C  |       3%      |     23.0     |
           |   ...    |      ...      |      ...     |
           |__________|_______________|______________|
#>

Write-Host "Welcome to the 2021 Weighted Draft Lottery for Jim's Dynasty League!`n"

Write-Host "Please confirm the following probablities:"

$p = Import-Csv .\probabilities.csv
$probabilityWeightList = @{}
ForEach ($row in $p){ 
    $Team = $($row.Team)
    $Probability = $($row.Probability)
    $Cumulative = $($row.Cumulative)

    $probabilityWeightList.add( $Team, $Probability )
    Write-host ("{0,-10}{1,4}{2,6}" -f $Team, $Probability, $Cumulative)
}

Write-Host "`nAre these values correct?"
$confirmation = Read-Host "[Y] Yes    [N] No (default is `"N`")"

if ($confirmation -eq "Y") { # Is not case sensitive, so it accepts 'Y' and 'y' for confirmation
    Write-Host "`nThe new draft order is:`n"

    $upperLimit = 100
    <# Algortithm explaination:
       Each team has a percentage value representing their odds.  The teams are fit on a line 
       wherein their range on the line is equal to their percentage point value.  For example, 
       consider the following teams: Team A (14%), Team B (9%), and Team C (3%).  They would be
       lined up on a line from 1 to 26 where Team A occupied the first 14 spots (#1-14), Team B 
       occupied the next 9 spots (#15-23), and Team C occupied the last 3 spots (#24-26).
       
       A random number is picked between 1 and the sum of the percentage values for all 
       not-yet-selected teams, inclusively.  Whatever team's range on the line occupies that random
       number is selected.  That team is then removed from the line and the process begins again 
       with a now shorter line and a now shorter maximum limit for the randomly generated number.
    #>
    for ($i = 1; $probabilityWeightList.Count -gt 0; $i++) {
        
        $randomNumber = Get-Random -Minimum 1 -Maximum $upperLimit

        $val = 0
        $selectedName = ""
        foreach ($tempTeam in $probabilityWeightList.Keys) {
            # Get the probability percentage for the team. Stored as a string with a '%' symbol
            $percent = $probabilityWeightList[$tempTeam]
            $stringLength = $percent.length
            [int]$percentNum = [convert]::ToInt32($percent.substring(0, $stringLength - 1), 10)
            $val += $percentNum

            if ($val -gt $randomNumber) {
                $selectedName = $tempTeam
                $upperLimit -= $percentNum
                $probabilityWeightList.Remove($tempTeam)
                break
            }
        }

        Write-Host "$i. $selectedName"
    }
} else {
    Write-Host "`nPlease update the CSV file and restart the script!"
}