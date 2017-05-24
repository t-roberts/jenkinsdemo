using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Xunit;
using Xunit.Sdk;

namespace Jenkins.Fass.Tests
{
    public class UnitTestExamples
    {
        [Fact]
        public void TestReturnSuccess()
        {
            Assert.True(true);
        }

        [Fact]
        public void TestReturnFail()
        {
            Assert.False(true);
        }
    }
}
