// MzScheme inetrface to system-level socket API.
// Copyright (C) 2007-2012  Vijay Mathew Pandyalakal
 
// This program is free software; you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation; either version 3 of the License, or
// (at your option) any later version.
  
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
  
// You should have received a copy of the GNU General Public License along
// with this program; If not, see <http://www.gnu.org/licenses/>.
  
// Please contact Vijay Mathew Pandyalakal if you need additional 
// information or have any questions.
// (Electronic mail: mathew.vijay@gmail.com)

#ifndef _SPARK_SOCKET_H_
#define _SPARK_SOCKET_H_

#include <vector>

namespace spark_socket
{
  spark::Status_code initialize(Scheme_Env* env);
  typedef int Socket;
  typedef std::vector<Socket> Sockets;
  Socket scheme_object_to_socket(Scheme_Object* obj);
  bool scheme_list_to_sockets(Scheme_Object* list, Sockets& out);
  Scheme_Object* sockets_to_scheme_list(const Sockets& sockets);
} // namespace spark_socket

#endif // #ifndef _SPARK_SOCKET_H_
