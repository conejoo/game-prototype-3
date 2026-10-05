using System.Collections.Concurrent;
using System.IO;
using System.Text;
using System.Threading.Tasks;

// Drain both pipes independently of PowerShell's polling thread. Flush each line
// so agents can inspect logs while a check is still running.
public static class GodotLogPump
{
    public static async Task CopyAsync(StreamReader source, string path, ConcurrentQueue<string> diagnostics)
    {
        using (var target = new StreamWriter(path, false, new UTF8Encoding(false)))
        {
            target.AutoFlush = true;
            string line;
            while ((line = await source.ReadLineAsync().ConfigureAwait(false)) != null)
            {
                await target.WriteLineAsync(line).ConfigureAwait(false);
                if (line.Contains("SCRIPT ERROR") || line.Contains("ERROR:") || line.Contains("WARNING:"))
                    diagnostics.Enqueue(line);
            }
        }
    }
}
