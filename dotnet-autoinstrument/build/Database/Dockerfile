FROM mcr.microsoft.com/mssql/server:2019-CU17-ubuntu-20.04

# Set environment variables
ENV ACCEPT_EULA="Y"
ENV MSSQL_SA_PASSWORD="StrongPass@123"
ENV MSSQL_PID="Developer"

# Default SQL Server TCP/Port.
EXPOSE 1433

# Run SQL Server process.
CMD [ "/opt/mssql/bin/sqlservr" ]